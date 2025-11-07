use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
};

// Declare and export the program's entrypoint
entrypoint!(process_instruction);

/// Simple counter program for Solana
/// Increments a counter stored in an account
pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    msg!("Counter program entrypoint");

    // Get the account to store counter data
    let accounts_iter = &mut accounts.iter();
    let account = next_account_info(accounts_iter)?;

    // Verify the account is owned by this program
    if account.owner != program_id {
        msg!("Counter account does not have the correct program id");
        return Err(ProgramError::IncorrectProgramId);
    }

    // Parse instruction: 0 = increment, 1 = decrement, 2 = reset
    let instruction = instruction_data
        .get(0)
        .ok_or(ProgramError::InvalidInstructionData)?;

    // Get current counter value
    let mut data = account.try_borrow_mut_data()?;
    let mut counter = u32::from_le_bytes(
        data[0..4]
            .try_into()
            .map_err(|_| ProgramError::InvalidAccountData)?,
    );

    // Process instruction
    match instruction {
        0 => {
            // Increment
            counter = counter.checked_add(1).ok_or(ProgramError::InvalidArgument)?;
            msg!("Counter incremented to: {}", counter);
        }
        1 => {
            // Decrement
            counter = counter.checked_sub(1).ok_or(ProgramError::InvalidArgument)?;
            msg!("Counter decremented to: {}", counter);
        }
        2 => {
            // Reset
            counter = 0;
            msg!("Counter reset to: 0");
        }
        _ => {
            msg!("Invalid instruction");
            return Err(ProgramError::InvalidInstructionData);
        }
    }

    // Write updated counter back to account
    data[0..4].copy_from_slice(&counter.to_le_bytes());

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use solana_program::clock::Epoch;
    use std::mem;

    #[test]
    fn test_counter_increment() {
        let program_id = Pubkey::default();
        let key = Pubkey::default();
        let mut lamports = 0;
        let mut data = vec![0; mem::size_of::<u32>()];
        let owner = program_id;

        let account = AccountInfo::new(
            &key,
            false,
            true,
            &mut lamports,
            &mut data,
            &owner,
            false,
            Epoch::default(),
        );

        let accounts = vec![account];
        let instruction_data = vec![0]; // Increment

        process_instruction(&program_id, &accounts, &instruction_data).unwrap();

        let counter = u32::from_le_bytes(data[0..4].try_into().unwrap());
        assert_eq!(counter, 1);
    }

    #[test]
    fn test_counter_decrement() {
        let program_id = Pubkey::default();
        let key = Pubkey::default();
        let mut lamports = 0;
        let mut data = vec![5, 0, 0, 0]; // Initial value = 5
        let owner = program_id;

        let account = AccountInfo::new(
            &key,
            false,
            true,
            &mut lamports,
            &mut data,
            &owner,
            false,
            Epoch::default(),
        );

        let accounts = vec![account];
        let instruction_data = vec![1]; // Decrement

        process_instruction(&program_id, &accounts, &instruction_data).unwrap();

        let counter = u32::from_le_bytes(data[0..4].try_into().unwrap());
        assert_eq!(counter, 4);
    }

    #[test]
    fn test_counter_reset() {
        let program_id = Pubkey::default();
        let key = Pubkey::default();
        let mut lamports = 0;
        let mut data = vec![42, 0, 0, 0]; // Initial value = 42
        let owner = program_id;

        let account = AccountInfo::new(
            &key,
            false,
            true,
            &mut lamports,
            &mut data,
            &owner,
            false,
            Epoch::default(),
        );

        let accounts = vec![account];
        let instruction_data = vec![2]; // Reset

        process_instruction(&program_id, &accounts, &instruction_data).unwrap();

        let counter = u32::from_le_bytes(data[0..4].try_into().unwrap());
        assert_eq!(counter, 0);
    }
}
