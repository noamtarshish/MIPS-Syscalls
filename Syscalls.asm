.data
	balance: .word 1000
	mainMenu: .ascii "Main Menu:\n"
	.ascii "1. Check Balance\n"
	.ascii "2. Deposit Money\n"
	.ascii "3. Withdraw Money\n"
	.asciiz "4. Exit\n"
	checkBalanceString: .asciiz "Current Balance: "
	enterDeposit: .asciiz "Enter deposit amount: "
	errorDeposit: .asciiz "Error: Deposit amount cannot exceed $5000\n"
	errorIllegal: .asciiz "Error: Input is not legal\n"
	enterWithdraw: .asciiz "Enter withdrawal amount: "
	errorWithdraw: .asciiz "Error: Insufficient funds or withdrawal limit exceeded\n"
	exitString: .asciiz "Thank you for using the ATM. Goodbye!"
	newLine: .asciiz "\n"
	dollar: .asciiz "$"
	buffer: .space 32   # buffer of 32 bytes for input

.text
main:
	lw $t1, balance
	
	mainMenu_loop:
		la $a0, mainMenu # load main menu string
		li $v0, 4
		syscall
		
		li $v0, 5 # read integer to ask from the user to choose option from the menu
		syscall
		
		beq $v0, 1, Check_Balance
		beq $v0, 2, Deopsit_Money
		beq $v0, 3, Withdraw_Money
		beq $v0, 4, Exit
		
		j Invalid_Input
		

	Check_Balance:
		li $v0, 4
		la $a0, checkBalanceString
		syscall
		
		li $v0, 4
		la $a0, dollar
		syscall 
		
		li $v0, 1
		move $a0, $t1
		syscall
			
		li $v0, 4
		la $a0, newLine
		syscall 
				
		j mainMenu_loop
########################################### Deposit ######################################################
    Deopsit_Money:
    		li $v0, 4
    		la $a0, enterDeposit 
    		syscall
    		
    		li $v0, 8 # Read string from the user
    		la $a0, buffer # Load address 
    		li $a1, 32 # Max input size
    		syscall

    		jal Convert_To_Integer
    
    		bgt $t2, 5000, Deposit_Error # Check if the amount is more 5000 - the limit
    		add $t1, $t1, $t2   # Add the deposit amount to the balance
    		j mainMenu_loop     

	Deposit_Error:
   		li $v0, 4
    		la $a0, errorDeposit  
    		syscall
		j mainMenu_loop
#################################### Withdraw ###########################################
    Withdraw_Money:
    		li $v0, 4
    		la $a0, enterWithdraw  
    		syscall
		
    		li $v0, 8 # Read string from the user
    		la $a0, buffer # Load address 
    		li $a1, 32 # Max input size
    		syscall
		
   		jal Convert_To_Integer
        	bgt $t2, 500, Withdraw_Error # Check if the amount is more than 500 - the limit 
        	bgt $t2, $t1, Withdraw_Error # Check if the amount is more than the balance
        	sub $t1, $t1, $t2 # Substract the amount from the balance
        	j mainMenu_loop     

    Withdraw_Error:
        li $v0, 4
        la $a0, errorWithdraw  
        syscall
        j mainMenu_loop	

	
	###### Convertion Function ##########
    Convert_To_Integer:
    		li $t2, 0 # Initialize $t2
    		move $t3, $a0 # Copy the address to $t3

    		convert_loop:
        		lb $t4, 0($t3) # Load the next character
        		beqz $t4, done_convert  # If null terminator, exit the loop (0)
        		beq $t4, 10, done_convert # If newline, exit the loop (10 - End of string)
        
        		li $t5, 48 # 48 represent number 0 in ASCII table
        		li $t6, 57 # 57 represent number 9 in ASCII table
        		blt $t4, $t5, Invalid_Input  # If not a digit, jump to invalid input function
        		bgt $t4, $t6, Invalid_Input

        		sub $t4, $t4, 48 # Convert character to numeric value by ASCII table
        		mul $t2, $t2, 10 # Multiply the current result by 10
        		add $t2, $t2, $t4 # Add the current number to the result

        		addi $t3, $t3, 1   
        		j convert_loop

    		done_convert:
        		jr $ra


	Invalid_Input:
		# handle invalid input - number not in range 1-4 or not a number
		li $v0, 4
		la $a0, errorIllegal # call the string that display error
		syscall
		j mainMenu_loop 

	################################### Exit #######################################################
	Exit:
		li $v0, 4
		la $a0, exitString
		syscall
		
		li $v0, 10
		syscall

