# G0 (move)
`G1 F[feedrate] X[pos] Y[pos] Z[pos]`

> Note: G0 seems to not be supported when looking at the Gcode list, but is working allright.

# G1 (move with extrusion)
`G1 F[feedrate] X[pos] Y[pos] Z[pos] E[value]`

# G21 (set units to mm)

# G28 (homing)

# G90 (absolute positioning)

# G91 (relative positioning)

# G92 (set position)
`G92 X[pos] Y[pos] Z[pos] E[value]`

Set axis to specified position.

> Note: `G92 E0` is frequently used to reset extruder position to "eliminate" accumulated errors.

# M82 (absolute extrusion)

# M83 (relative extrusion)

# M104 (set tool temp)
`M104 T[tool number] S[extruder body] C[cold-end] H[nozzle]`

# M105 (get temperature)

# M107 (turn off cooling fan)

# M109 (set & wait tool temp)
`M109 T[tool number] S[extruder body] C[cold-end] H[nozzle]`

# M110 (reset host line numbering)

# M114 (get current position)

# M115 (get firmware version)

# M140 (set bed temperature)
`M140 S[temperature]`

# M190 (set & wait bed temperature)
`M190 S[temperature]`

# T (select tool)
`T[tool number]`

> Note : tool number starts at 1.

# D0 (relative move)
`D0 F[feedrate] X[pos] Y[pos] Z[pos] E[value]` 

Similar to G1.
move relative to the previous one.

# D1 (inverse kinematics move | DEBUG)
`D1 X[pos] Y[pos] Z[pos] E[value]`

Compute inverse kinematics and send result.

# D2 (get mobiles position)
Return the current position of the "mobiles" (axis carriage) along their axis.

# D5 (change Delta radius)
`D5 A[value] B[value] C[value]`

# D6 (change Delta rods length)
`D6 A[value] B[value] C[value]`

# D7 (change extruders full-steps/mm)
`D7 [extruder letter - E,F,G,H][value]`

> Note: Default value seems to be 312.5

# D8 (change microstepping)
`D8 [axis letter - E,F,G,H,S] T[value]`

> Note: Possible values are 1 (full step), 2, 4, 8, 16, 32.

# D9 (wait for all temp)
`D9 V1000000`

# D10 (enable motors)

# D11 (disable motors)

# D12 (enable mains power)
Activate AC (110/220V) to power the bed.
Locking doors and homing required.

# D13 (disable mains power)

# D14 (change acceleration)
`D14 A[value]`

> Note: Default value is 500.

# D15 (bed levelling)
`D15 F[feedrate]`

> Note: default feedrate is 10.

# D17 (move by steps)
`D17 [axis letter][value]`

# D18 (set polynomial compensation)
D18 I[compensation indice] J[compensation indice] P[polynomial parameter]

Order 3 polynomial compensation for plate levelling.

> Note: 0 <= I <= 2 and 0 <= J <= 9

# D19 (get time from start in ms)

# D20 (set temperature PID)
`D20 [item] P[value] I[value] D[value]`

> Note: item possible values: 
> R-> Radial heater
> B-> Bed heater
> T[number]-> Tool heater (global)
> S[number]-> Extruder body heater
> C[number]-> Extruder cold-end heater
> H[number]-> Extruder nozzle heater

# D21 (set extruder cartesian offset)
`D21 E[number] X[position] Y[position] Z[position]`

# D22 (set temperature target)
`D22 [item] S[value]`

> Note: item possible values: 
> R-> Radial heater
> B-> Bed heater
> T[number]-> Tool heater (global)
> S[number]-> Extruder body heater
> C[number]-> Extruder cold-end heater
> H[number]-> Extruder nozzle heater

# D23 (pellet mixer)
`D23 T[number] V[enable] S[speed]`

> Note: enable values are either 0 (disabled) or 1 (enabled)

# D24 (set max junction acceleration)
`D24 A[value]`

"Speed for negociating curves"

> Note: default value is 5

# D25 (set max acceleration)
`D25 V[value]`

Limit speed change between 2 axes movement command.

# D26 (set z_limit check)
`D26 V[enable]`

> Note: enable values are either 0 (disabled) or 1 (enabled).

# D27 (set door locking protection)
`D27 V[enable]`

> Note: enable values are either 0 (disabled) or 1 (enabled).

# D28 (lock doors)
`D28 V[enable]`

> Note: enable values are either 0 (disabled) or 1 (enabled).

# D29 (enable xy_limits)
`D29 V[enable]`

> Note: enable values are either 0 (disabled) or 1 (enabled).

# D30 (cool chamber)
`D30 V[value]`

# D31 (set bed lighting)
`D31 V[value]`

# D32 (macro to lock doors)
Similar to `D28 V1`

# D33 (set current Z pos as Z0)

# D34 (set status led color)
`D34 R[value] G[value] B[value]`

> Note: 0 <= value <= 255.

# D35 (live nozzle offset)
`D35 Z[value]`

# D106 (start extruder)
`D106 E[number] S[speed] C[direction]`

> Note: direction values are either 0 (clockwise) or 1 (counter-clockwise).

# D107 (stop extruder)
`D107 E[number]`

# D200 (read on I2C)

# D201 (write on I2C)

# D301 (I2C update)
