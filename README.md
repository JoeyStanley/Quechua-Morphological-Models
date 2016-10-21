# Quechua Morphology
This repository contains two Perl scripts that were used in paper I presented at the 3rd Annual Linguistics Conference at the University of Georgia. For more information, see [Stanley (2016)](https://www.academia.edu/29035896/An_EWP_Model_of_Quechua_Agreement_Further_Evidence_Against_DM).

Note: I had not heard of github when I wrote these scripts, they were not written with the intention of other people seeing them. Eventually I'll modify them to make them easier for others to run and understand.

### Background
In my presentation, I presented two theoretical morphological models of the Quechua verbal paradigm, which has a fair amount of regularity but also quite a bit of irregularity. I show that the Extended Word-and-Paradigm model is superior to the Distributed Morphology model. 

Since I was working with a large paradigm (96 cells), there was no way I was going to work with the potentially many rules by hand. I wrote these scripts to help me check my work and make sure the rules work. The programs are not sophisticated enough to write the rules for me or even apply them in the correct order, so I simply had to figure out what rules to write and then figure out when they would apply.

The `QuechuaDM.pl` file runs the Distributed Morphology model and the `QuechuaEWP.pl` file is the Extended Word-and-Paradigm mode. 

### How to use these files

These scripts are written in Perl and do not require any other files. To run them, simply navigate to the directory and type the following:

```Bash
> perl QuechuaDM.pl
```

or 

```Bash
> perl QuechuaEWP.pl
```

In both files, the correct output is hard-coded into the script. Each cell in the paradigm is processed, and pass through all the rules. The guess is then compared against the final form, with some feedback about whether it's done or not. 

### Todo
Add a separate file with the final forms. Will save many lines of code in both files if the information is just read in.

Updated: October 21, 2016
