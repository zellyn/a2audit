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
