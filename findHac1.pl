#! /usr/bin/perl -w
#
use strict;
my $intronLength=$ARGV[0];
my $stemLength=$ARGV[1];
my $allowGU=$ARGV[2];

open(FILE,$ARGV[3])||die $!;
my $name=<FILE>;
my @lines=<FILE>;
close FILE;
my $seq="";

foreach(@lines){
	s/\n//g;
	$seq.=$_;
}

#print $seq,"\n";
my $seqlength=length($seq);
print $ARGV[3],"\t",$seqlength,"\n";

my %candidates1;
my @positions1;
my %candidates2;
my @positions2;

my $pattern1="c.g..g[a|t|c]";
my $pattern2="[a|t|g]c..c.g";
for(my $i=$stemLength; $i<$seqlength-7-$stemLength; $i++){
	my $subseq=substr($seq,$i,7);
	#print $subseq,"\n";
	if($subseq=~m/^$pattern1/){
	#if($subseq=~m/[a|t|g]c..c.g/){
		my $head=substr($seq,$i-$stemLength,$stemLength);
		my $tail=substr($seq,$i+7,$stemLength);
		my $isComp=&isComplementary($head,$tail,$allowGU,0);
		#print $i,"\t",$isComp,"\t",$subseq,"\t",$head,"\t",$tail,"\n";

		if($isComp==1){
			#print $i,"\t",$subseq,"\t",$head,"\t",$tail,"\n";
			$candidates1{$i}="+\t$subseq\t$head\t$tail";
			push @positions1,$i;
		}
	}
	if($subseq=~m/^$pattern2/){
		my $head=substr($seq,$i-$stemLength,$stemLength);
		my $tail=substr($seq,$i+7,$stemLength);
		my $isComp=&isComplementary($head,$tail,$allowGU,1);
		#print $i,"\t",$isComp,"\t",$subseq,"\t",$head,"\t",$tail,"\n";

		if($isComp==1){
			#print $i,"\t",$subseq,"\t",$head,"\t",$tail,"\n";
			$candidates2{$i}="-\t$subseq\t$head\t$tail";
			push @positions2,$i;
		}

	}	
}

for(my $i=0; $i<$#positions1; $i++){
	my $p1=$positions1[$i];
	my $p2=$positions1[$i+1];
	my $distance=$p2-$p1;
	my $index=1;
	while($distance<$intronLength){
		if(($distance % 3)>0){
			print $positions1[$i],"\t",$p2,"\t",$distance,"\t",$candidates1{$p1},"\t",$candidates1{$p2},"\n";
		}
		$index++;
		if($i+$index>$#positions1){
			$distance=1000;
		}else{
			$p2=$positions1[$i+$index];
			$distance=$p2-$p1;
		}
	}
}

for(my $i=0; $i<$#positions2; $i++){
	my $p1=$positions2[$i];
	my $p2=$positions2[$i+1];
	my $distance=$p2-$p1;
	my $index=1;
	while($distance<$intronLength){
		if(($distance % 3)>0){
			print $positions2[$i],"\t",$p2,"\t",$distance,"\t",$candidates2{$p1},"\t",$candidates2{$p2},"\n";
		}
		$index++;
		if($i+$index>$#positions2){
			$distance=1000;
		}else{
			$p2=$positions2[$i+$index];
			$distance=$p2-$p1;
		}
	}
}


sub isComplementary{
	my %complementary;
	$complementary{"t"}="a";
	$complementary{"a"}="t";
	$complementary{"c"}="g";
	$complementary{"g"}="c";
	
	my($head,$tail,$allowGU,$reverse)=@_;
	if($allowGU==1 && $reverse==0){
		$complementary{"t"}="ag";
		$complementary{"g"}="ct";
	}elsif($allowGU==1 && $reverse==1){
		$complementary{"a"}="tc";
		$complementary{"c"}="ga";
	}
	$head=~s/\s//g;
	$tail=~s/\s//g;
	my @h=split("",$head,-1);
	my @t=split("",$tail,-1);
	my $hl=$#h-1;
	#print $hl,"\n";
	for(my $i=0; $i<=$hl; $i++){
		my $bp1=$h[$i];
		my $bp2=$t[$hl-$i];
		my $cbp1=$complementary{$bp1};
		if(defined $bp2 && defined $cbp1){
			if(!($cbp1=~m/$bp2/)){
				return 0;
			}
		}else{
			return 0;
		}
	}
	return 1;
}

