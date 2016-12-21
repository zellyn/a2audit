# V0 Errors

## E0001

The machine identification routines from http://www.1000bit.it/support/manuali/apple/technotes/misc/tn.misc.02.html failed to identify the model.

## E0002

The current version of the audit program doesn't support the identified machine.

## E0003

We tried to put the language card into read bank 1, write bank 1, but failed to write.

## E0004

We tried to put the language card into read RAM, write RAM, but failed to write.

## E0005

We tried to put the language card into read bank 2, write bank 2, but failed to write.

## E0006

Read $C088 (read bank 1), but the language card is still reading bank 2.

## E0007

Read $C088 (read bank 1), but the language card is reading ROM.

## E0008

Read $C088 (read bank 1), but the check byte ($D17B) is an unknown value.

## E0009

Read $C088 (read bank 1, write-protected), but successfully wrote byte ($D17B).

## E000A

Read $C080 (read bank 2), but the language card is still reading bank 1.

## E000B

Read $C080 (read bank 2), but the language card is reading ROM.

## E000C

Read $C080 (read bank 2), but the check byte ($D17B) is an unknown value.

## E000D

Read $C080 (read bank 2, write-protected), but successfully wrote byte ($D17B).

## E000E

Read $C081 (read ROM), but the language card is still reading bank 1.

## E000F

Read $C081 (read ROM), but the language card is reading bank 2.

## E0010

Read $C081 (read ROM), but the check byte ($D17B) is an unknown value.

## E0011

Read $C081 (read ROM), but successfully modified byte ($D17B).

## E0012

Read $C089 (read ROM), but the language card is still reading bank 1.

## E0013

Read $C089 (read ROM), but the language card is reading bank 2.

## E0014

Read $C089 (read ROM), but the check byte ($D17B) is an unknown value.

## E0015

Read $C089 (read ROM), but successfully modified byte ($D17B).

## E0016

Read $C08B (read bank 1), but the language card is still reading bank 2.

## E0017

Read $C08B (read bank 1), but the language card is reading ROM.

## E0018

Read $C08B (read bank 1); byte should have been previously incremented from ROM ($53) to $54 because of lda $C089 after previous lda $C081.

## E0019

Read $C08B (read bank 1), but the check byte ($D17B) is an unknown value.

## E001A

Read $C083 (read bank 2), but the language card is still reading bank 1.

## E001B

Read $C083 (read bank 2), but the language card is reading ROM.

## E001C

Read $C083 (read bank 2); byte should have been previously NOT been writable to be decremented from ROM ($53) to $52 because of single lda $C081 after previous lda $C080.

## E001D

Read $C083 (read bank 2), but the check byte ($D17B) is an unknown value.

## E001E

We initialized $D17B in RAM bank 1 to $11, $D17B in RAM bank 2 to $22, and $FE1F in RAM to $33. Then, we perform a testdata-driven sequence of LDA and STA to the $C08X range. Finally we (try to) increment $D17B and $FE1F. Then we test (a) the current live value in $D17B, (b) the current live value in $FE1F, (c) the RAM bank 1 value of $D17B, (d) the RAM bank 2 value of $D17B, and (e) the RAM value of $FE1F, to see whether they match expected values. $D17B is usually $53 in ROM, and $FE1F is usally $60. For more information on the operation of the language card soft-switches, see Understanding the Apple IIe, by James Fielding Sather, Pg 5-24.
