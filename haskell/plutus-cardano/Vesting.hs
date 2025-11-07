{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}

module Vesting where

import           PlutusTx
import           PlutusTx.Prelude
import qualified PlutusTx.Builtins as Builtins
import           Plutus.V2.Ledger.Api
import           Plutus.V2.Ledger.Contexts
import qualified Ledger.Typed.Scripts as Scripts
import           Ledger.Ada           as Ada

-- | Vesting schedule parameters
data VestingParams = VestingParams
    { beneficiary :: PaymentPubKeyHash
    -- ^ The public key hash of the beneficiary
    , deadline    :: POSIXTime
    -- ^ The deadline for claiming the vested funds
    } deriving (Show, Generic, FromJSON, ToJSON)

PlutusTx.makeLift ''VestingParams

-- | Vesting datum (stored on-chain)
newtype VestingDatum = VestingDatum
    { vestingAmount :: Integer
    } deriving (Show)

PlutusTx.unstableMakeIsData ''VestingDatum

-- | Vesting redeemer (action to perform)
data VestingRedeemer = Claim | Cancel
    deriving (Show)

PlutusTx.unstableMakeIsData ''VestingRedeemer

-- | The vesting validator
{-# INLINABLE mkValidator #-}
mkValidator :: VestingParams -> VestingDatum -> VestingRedeemer -> ScriptContext -> Bool
mkValidator params _ redeemer ctx =
    case redeemer of
        Claim  -> traceIfFalse "beneficiary's signature missing" signedByBeneficiary &&
                  traceIfFalse "deadline not reached" deadlineReached
        Cancel -> traceIfFalse "deadline passed" (not deadlineReached)
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    signedByBeneficiary :: Bool
    signedByBeneficiary = txSignedBy info (unPaymentPubKeyHash $ beneficiary params)

    deadlineReached :: Bool
    deadlineReached = contains (from $ deadline params) (txInfoValidRange info)

-- | Typed validator
data Vesting
instance Scripts.ValidatorTypes Vesting where
    type instance DatumType Vesting = VestingDatum
    type instance RedeemerType Vesting = VestingRedeemer

typedValidator :: VestingParams -> Scripts.TypedValidator Vesting
typedValidator params = Scripts.mkTypedValidator @Vesting
    ($$(PlutusTx.compile [|| mkValidator ||]) `PlutusTx.applyCode` PlutusTx.liftCode params)
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.wrapValidator @VestingDatum @VestingRedeemer

-- | The validator script
validator :: VestingParams -> Validator
validator = Scripts.validatorScript . typedValidator

-- | The script address
scriptAddress :: VestingParams -> Address
scriptAddress = scriptHashAddress . validatorHash . validator

-- | Helper: validator hash
validatorHash :: Validator -> ValidatorHash
validatorHash = Scripts.validatorHash

-- | Off-chain code example
grab :: VestingParams -> Integer -> Contract () VestingSchema Text ()
grab params amount = do
    let tx = mustPayToTheScript (VestingDatum amount) (Ada.lovelaceValueOf amount)
    ledgerTx <- submitTxConstraints (typedValidator params) tx
    void $ awaitTxConfirmed $ getCardanoTxId ledgerTxclaim :: VestingParams -> Contract () VestingSchema Text ()
claim params = do
    now <- currentTime
    utxos <- utxosAt $ scriptAddress params
    let orefs   = fst <$> Map.toList utxos
        lookups = Constraints.unspentOutputs utxos  <>
                  Constraints.otherScript (validator params)
        tx      = mconcat [Constraints.mustSpendScriptOutput oref (Redeemer $ PlutusTx.toBuiltinData Claim) | oref <- orefs] <>
                  Constraints.mustValidateIn (from now)
    ledgerTx <- submitTxConstraintsWith @Vesting lookups tx
    void $ awaitTxConfirmed $ getCardanoTxId ledgerTx
