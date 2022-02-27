EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 6
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L SparkFun-DigitalIC:P8X32A-Q44 U5
U 2 1 6183E646
P 6700 3300
F 0 "U5" H 6750 4365 50  0000 C CNN
F 1 "P8X32A-Q44" H 6750 3250 50  0000 C CNN
F 2 "P8X32A-Q44" H 6730 3450 20  0001 C CNN
F 3 "" H 6700 3300 50  0001 C CNN
	2    6700 3300
	1    0    0    -1  
$EndComp
Text GLabel 7650 2500 2    50   Input ~ 0
RxD
Text GLabel 7650 2600 2    50   Input ~ 0
TxD
Wire Wire Line
	7400 2500 7650 2500
Wire Wire Line
	7400 2600 7650 2600
Text GLabel 7650 2800 2    50   Input ~ 0
I2C-SCL
Text GLabel 7650 2700 2    50   Input ~ 0
I2C-SDA
Wire Wire Line
	7400 2700 7650 2700
Wire Wire Line
	7400 2800 7650 2800
Text GLabel 5900 2500 0    50   Input ~ 0
V
Text GLabel 5900 2600 0    50   Input ~ 0
H
Text GLabel 5900 2700 0    50   Input ~ 0
B0
Text GLabel 5900 2800 0    50   Input ~ 0
B1
Text GLabel 5900 2900 0    50   Input ~ 0
G0
Text GLabel 5900 3000 0    50   Input ~ 0
G1
Text GLabel 5900 3100 0    50   Input ~ 0
R0
Text GLabel 5900 3200 0    50   Input ~ 0
R1
Wire Wire Line
	5900 2500 6100 2500
Wire Wire Line
	5900 2600 6100 2600
Wire Wire Line
	5900 2700 6100 2700
Wire Wire Line
	5900 2800 6100 2800
Wire Wire Line
	5900 2900 6100 2900
Wire Wire Line
	5900 3000 6100 3000
Wire Wire Line
	5900 3100 6100 3100
Wire Wire Line
	5900 3200 6100 3200
Text GLabel 3700 2300 0    50   Input ~ 0
D0
Text GLabel 3700 2500 0    50   Input ~ 0
D1
Text GLabel 3700 2700 0    50   Input ~ 0
D2
Text GLabel 3700 2900 0    50   Input ~ 0
D3
Text GLabel 3700 3750 0    50   Input ~ 0
D4
Text GLabel 3700 3950 0    50   Input ~ 0
D5
Text GLabel 3700 4150 0    50   Input ~ 0
D6
Text GLabel 3700 4350 0    50   Input ~ 0
D7
Wire Wire Line
	3700 2300 4000 2300
Wire Wire Line
	3700 2500 4000 2500
Wire Wire Line
	3700 2700 4000 2700
Wire Wire Line
	3700 2900 4000 2900
Wire Wire Line
	3700 3750 4000 3750
Wire Wire Line
	3700 3950 4000 3950
Wire Wire Line
	3700 4150 4000 4150
Wire Wire Line
	3700 4350 4000 4350
$Comp
L 74xx_IEEE:74LS257 U1
U 1 1 6183E674
P 2700 2550
F 0 "U1" H 2700 3316 50  0000 C CNN
F 1 "74LS257" H 2700 3225 50  0000 C CNN
F 2 "" H 2700 2550 50  0001 C CNN
F 3 "" H 2700 2550 50  0001 C CNN
	1    2700 2550
	1    0    0    -1  
$EndComp
Text GLabel 1800 2350 0    50   Input ~ 0
A0
Text GLabel 1800 2550 0    50   Input ~ 0
A1
Text GLabel 1800 2750 0    50   Input ~ 0
A2
Text GLabel 1800 2950 0    50   Input ~ 0
A3
$Comp
L 74xx_IEEE:74LS257 U2
U 1 1 6183E67E
P 2700 4000
F 0 "U2" H 2700 4766 50  0000 C CNN
F 1 "74LS257" H 2700 4675 50  0000 C CNN
F 2 "" H 2700 4000 50  0001 C CNN
F 3 "" H 2700 4000 50  0001 C CNN
	1    2700 4000
	1    0    0    -1  
$EndComp
$Comp
L 74xx_IEEE:74LS257 U3
U 1 1 6183E684
P 4550 2500
F 0 "U3" H 4550 3266 50  0000 C CNN
F 1 "74LS257" H 4550 3175 50  0000 C CNN
F 2 "" H 4550 2500 50  0001 C CNN
F 3 "" H 4550 2500 50  0001 C CNN
	1    4550 2500
	1    0    0    -1  
$EndComp
$Comp
L 74xx_IEEE:74LS257 U4
U 1 1 6183E68A
P 4550 3950
F 0 "U4" H 4550 4716 50  0000 C CNN
F 1 "74LS257" H 4550 4625 50  0000 C CNN
F 2 "" H 4550 3950 50  0001 C CNN
F 3 "" H 4550 3950 50  0001 C CNN
	1    4550 3950
	1    0    0    -1  
$EndComp
Wire Wire Line
	5100 2350 5650 2350
Wire Wire Line
	5650 2350 5650 3300
Wire Wire Line
	5650 3300 6100 3300
Wire Wire Line
	5100 2550 5550 2550
Wire Wire Line
	5550 2550 5550 3400
Wire Wire Line
	5550 3400 6100 3400
Wire Wire Line
	5100 2750 5450 2750
Wire Wire Line
	5450 2750 5450 3500
Wire Wire Line
	5450 3500 6100 3500
Wire Wire Line
	5100 2950 5350 2950
Wire Wire Line
	5350 2950 5350 3600
Wire Wire Line
	5350 3600 6100 3600
Wire Wire Line
	5100 3800 5350 3800
Wire Wire Line
	5350 3800 5350 3700
Wire Wire Line
	5350 3700 6100 3700
Wire Wire Line
	5100 4000 5450 4000
Wire Wire Line
	5450 4000 5450 3800
Wire Wire Line
	5450 3800 6100 3800
Wire Wire Line
	5100 4200 5550 4200
Wire Wire Line
	5550 4200 5550 3900
Wire Wire Line
	5550 3900 6100 3900
Wire Wire Line
	5100 4400 5650 4400
Wire Wire Line
	5650 4400 5650 4000
Wire Wire Line
	5650 4000 6100 4000
Wire Wire Line
	1800 2350 2150 2350
Wire Wire Line
	1800 2550 2150 2550
Wire Wire Line
	1800 2750 2150 2750
Wire Wire Line
	1800 2950 2150 2950
Text GLabel 1800 3800 0    50   Input ~ 0
A4
Text GLabel 1800 4000 0    50   Input ~ 0
A5
Text GLabel 1800 4200 0    50   Input ~ 0
A6
Text GLabel 1800 4400 0    50   Input ~ 0
A7
Wire Wire Line
	1800 3800 2150 3800
Wire Wire Line
	1800 4000 2150 4000
Wire Wire Line
	1800 4200 2150 4200
Wire Wire Line
	1800 4400 2150 4400
Text GLabel 1800 2450 0    50   Input ~ 0
A8
Text GLabel 1800 2650 0    50   Input ~ 0
A9
Text GLabel 1800 2850 0    50   Input ~ 0
A10
Text GLabel 1800 3050 0    50   Input ~ 0
A11
Wire Wire Line
	1800 2450 2150 2450
Wire Wire Line
	1800 2650 2150 2650
Wire Wire Line
	1800 2850 2150 2850
Wire Wire Line
	1800 3050 2150 3050
Text GLabel 1800 3900 0    50   Input ~ 0
A12
Text GLabel 1800 4100 0    50   Input ~ 0
A14
Text GLabel 1800 4300 0    50   Input ~ 0
A14
Text GLabel 1800 4500 0    50   Input ~ 0
A15
Wire Wire Line
	1800 3900 2150 3900
Wire Wire Line
	1800 4100 2150 4100
Wire Wire Line
	1800 4300 2150 4300
Wire Wire Line
	1800 4500 2150 4500
Wire Wire Line
	3250 2400 4000 2400
Wire Wire Line
	3250 2600 4000 2600
Wire Wire Line
	3250 2800 4000 2800
Wire Wire Line
	3250 3000 4000 3000
Wire Wire Line
	3250 3850 4000 3850
Wire Wire Line
	3250 4050 4000 4050
Wire Wire Line
	3250 4250 4000 4250
Wire Wire Line
	3250 4450 4000 4450
Wire Wire Line
	4000 2050 3800 2050
Wire Wire Line
	3800 2050 3800 3500
Wire Wire Line
	3800 3500 4000 3500
Wire Wire Line
	2150 2100 1950 2100
Wire Wire Line
	1950 2100 1950 3550
Wire Wire Line
	1950 3550 2150 3550
Wire Wire Line
	4000 3600 3900 3600
Wire Wire Line
	3900 3600 3900 2150
Wire Wire Line
	3900 2150 4000 2150
Wire Wire Line
	3900 3600 3900 4650
Wire Wire Line
	3900 4650 7650 4650
Wire Wire Line
	7650 4650 7650 4000
Wire Wire Line
	7650 4000 7400 4000
Connection ~ 3900 3600
Wire Wire Line
	3800 3500 3800 4750
Connection ~ 3800 3500
Wire Wire Line
	2150 2200 2050 2200
Wire Wire Line
	2050 2200 2050 3650
Wire Wire Line
	2050 3650 2150 3650
Wire Wire Line
	2050 3650 2050 5000
Wire Wire Line
	2050 5000 7850 5000
Wire Wire Line
	7850 5000 7850 3900
Wire Wire Line
	7850 3900 7400 3900
Connection ~ 2050 3650
Wire Wire Line
	1950 3550 1950 4750
Connection ~ 1950 3550
Text Notes 7450 4000 0    50   ~ 0
A~D
Text Notes 7450 3900 0    50   ~ 0
AH~AL
Text GLabel 7900 3800 2    50   Input ~ 0
R~W
Wire Wire Line
	7400 3800 7900 3800
Text GLabel 7650 3700 2    50   Input ~ 0
CLK
Wire Wire Line
	7400 3700 7650 3700
$Comp
L power:GND #PWR02
U 1 1 6183E6EC
P 3800 4750
F 0 "#PWR02" H 3800 4500 50  0001 C CNN
F 1 "GND" H 3805 4577 50  0000 C CNN
F 2 "" H 3800 4750 50  0001 C CNN
F 3 "" H 3800 4750 50  0001 C CNN
	1    3800 4750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR01
U 1 1 6183E6F2
P 1950 4750
F 0 "#PWR01" H 1950 4500 50  0001 C CNN
F 1 "GND" H 1955 4577 50  0000 C CNN
F 2 "" H 1950 4750 50  0001 C CNN
F 3 "" H 1950 4750 50  0001 C CNN
	1    1950 4750
	1    0    0    -1  
$EndComp
$EndSCHEMATC
