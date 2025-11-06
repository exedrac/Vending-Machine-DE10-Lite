# Vending-Machine-DE10-Lite
Use Quartus Prime Lite Version 18.1
## Build Instructions
1. Create a directory name without any spaces and outside of any cloud service such as OneDrive
2. Place .vhdl files in directory
3. File -> New Quartus Prime Project
4. Select project directory from before. Set the project name to the same as the project directory.
5. Add Files to Project
6. Family, Device, & Board Setting
7. Set Family -> MAX 10 (DA/DF/DC/SA/SC), and Device -> MAX 10 DA
8. Under Available Devices, scroll to get to 10M50DAF484C7G and select it
9. EDA Tool Settings
10. Simulation -> ModelSim-Altera, Format -> VHDL

11. Assignments -> Settings -> Compiler Settings -> VHDL Input: Select VHDL 2008
12. Assignments -> Import Assignments: Point to your downloaded DE10_Lite.qsf file. This can be verified under Assignments -> Pin Planner, where the bottom tab should be highlighted with the top node being CLOCK_50 set to PIN_P11.
13. Tools -> Timing Analyzer
14. Wait for new tab to open, then go File -> New SDC File, and paste the contents of Basic_SDC.sdc into the file
15. File -> Save As: Name it the same as your project name as a .sdc file
16. Assignments -> Device -> Device and Pin Options -> Configuration -> Configuration Mode: Select single uncompressed Image with Memory Initialization (512Kbits UFM)

17. From the main page, in project navigator, set the hierarchy option to files so you can view the files in the directory
18. Right click vending_machine_de10.vhdl and set as top level entity
19. Start Compilation (Ctrl + L) and wait for completion
21. Connect the board via USB-B to USB-C cable to computer
22. Tools -> Programmer -> Hardware Setup: Select the target device
23. Click Start and Program the Board.

## Testbench Setup
- Assignments -> Settings -> EDA Tool Settings -> Simulation
- Select the "Compile Test Bench" option, and click Test Benches
- New Test Bench
- Test bench name: enter "vending_machine_tb" 
- End simulation at 5000ns
- Select file_name, then click add so that the file shows under File Name
- Click OK, then select the test bench and click OK again
- Click Apply
- Set "vending_machine_tb" to top level entity, similar to before
- Tools -> Run Simulation Tool -> RTL Simulation
- Press F to view full logic
- Ctrl + Click each signal, then right click on any signal -> Radix -> Unsigned: This lets you view all the numbers in the logic.

## Extras
- Created a testbench skeleton file can be implemented into any desired project

