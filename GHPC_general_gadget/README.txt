This folder contains the source code (HDL files) of the GHPC general gadget

The main module is GHPC_Gadget, whose generics can be adjusted to the fit into the desired needs, for example:

- the number of inputs and output bits (of the underlying function to be masked),
- whether GHPC or GHPC_LL is desired (normal or low-latency version)

The desired function to be masked should be defined in the module GHPC_Step1 line 62:
In the given file, it realizes a 2-input AND gate:

        FuncOut(I)(0) <= in0_comb(I)(0) AND in0_comb(I)(1); -- output: FuncOut(I)
                                                            -- input:  in0_comb(I)

## Licensing
Copyright (c) 2021, David Knichel, Pascal Sadrich, Amir Moradi
All rights reserved.

Please see `LICENSE` for further license instructions.

## Publications
D. Knichel, P. Sasdrich, A. Moradi: "Generic Hardware Private Circuits - Towards Automated Generation of Composable Secure Gadgets" (TCHES 2022, Issue 1) https://eprint.iacr.org/2021/247
