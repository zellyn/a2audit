# V0 Errors

## E0000

This is a data-driven test of Language Card operation. We initialize $D17B in RAM bank 1 to $11, $D17B in RAM bank 2 to $22, and $FE1F in RAM to $33. Then, we perform a testdata-driven sequence of LDA and STA to the $C08X range. Finally we (try to) increment $D17B and $FE1F. Then we test (a) the current live value in $D17B, (b) the current live value in $FE1F, (c) the RAM bank 1 value of $D17B, (d) the RAM bank 2 value of $D17B, and (e) the RAM value of $FE1F, to see whether they match expected values. $D17B is usually $53 in ROM, and $FE1F is usally $60. For more information on the operation of the language card soft-switches, see Understanding the Apple IIe, by James Fielding Sather, Pg 5-24.

## E0000

We tried to put the language card into read RAM, write RAM, but failed to write.

## E0000

We tried to put the language card into read bank 1, write bank 1, but failed to write.

## E0000

We tried to put the language card into read bank 2, write bank 2, but failed to write.

## E0001

The machine identification routines from http://www.1000bit.it/support/manuali/apple/technotes/misc/tn.misc.02.html failed to identify the model.

## E0002

The current version of the audit program doesn't support the identified machine.

## E0003

Soft-switched for either RAMRD or RAMWRT read as set, which means we're either reading from, or writing to, auxiliary RAM. Please press RESET and run the test again to start in a known-good state.

## E0004

We tried to put the language card into read bank 1, write bank 1, but failed to write.

## E0005

We tried to put the language card into read RAM, write RAM, but failed to write.

## E0006

We tried to put the language card into read bank 2, write bank 2, but failed to write.

## E0007

This is a data-driven test of Language Card operation. We initialize $D17B in RAM bank 1 to $11, $D17B in RAM bank 2 to $22, and $FE1F in RAM to $33. Then, we perform a testdata-driven sequence of LDA and STA to the $C08X range. Finally we (try to) increment $D17B and $FE1F. Then we test (a) the current live value in $D17B, (b) the current live value in $FE1F, (c) the RAM bank 1 value of $D17B, (d) the RAM bank 2 value of $D17B, and (e) the RAM value of $FE1F, to see whether they match expected values. $D17B is usually $53 in ROM, and $FE1F is usally $60. For more information on the operation of the language card soft-switches, see Understanding the Apple IIe, by James Fielding Sather, Pg 5-24.
