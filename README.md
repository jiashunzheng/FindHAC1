This is an old program I wrote with Perl to find Hac1 like structure in DNA sequences, using a calonical sequence from S.cerevisiae as a template. 

In a terminal, cd to the directory where you save these files:
perl findHac1.pl 30 3 1 chromosome1.fasta
(30 for 30bp intron length limit, 3 for stem length, 1 for allow GU
pair(use 0 if do not allow GU pair))

Here you can also try different parameters, for example, to change the
intron length to 50 use:

perl findHac1.pl 50 3 1 chromosome1.fasta(replaced with your target
sequence file in fasta format).


