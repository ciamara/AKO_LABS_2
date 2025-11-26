# 32bit masm x86 architecture
## LAB1       
### utf-8 validator       
-> .asm program for parsing and detecting errors in utf-8 encoding           
-> script in python for generating invalid utf-8 files      
-> some premade files to test the .asm program         

## LAB2                 
### 64 bit hex value representing 0.xxxxxxxxxx number to decimal representation 0.xxxxxxx with following zeros deleted                   
-> .asm program for converting a 64 bit hex value to decimal representation     
-> if decimal representation has zeros and no meaningful value after, zeros are cut and not displayed, ex.    
      - 0.125000000000 would be written out as 0.125
      - 0.0000000000000 would be written out as 0.0
      
## LAB3
### .asm subprogram for setting an environment variable of name and value called from .c         
-> included checking if variable exists, if exists stop program and dont overwrite         
-> also included verification in .c after creating to check if variable has been set correctly       
-> arguments are passed and used as utf-16
