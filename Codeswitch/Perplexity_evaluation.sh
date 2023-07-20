#! /bin/bash

var=$((1))
#order="all"

read -p "Order: " order
read -p "Linear interpolation 1-2: " linear12
read -p "Linear interpolation 2-3: " linear23

# Initialiye smoothing values list
smooth_list=(0 0.01 0.001)

# Loop through the smoothing values list
for add_smoothing in "${smooth_list[@]}"
do
	echo "-----------------------------------" >> y
	echo "Smoothing $add_smoothing" >> y
	if [ $order == 'all' ]
		then
		
			# ORDER 1
			./ngram-count -text train_Only_Malay_norm.txt -vocab cs_vocab -order 1  -addsmooth "$add_smoothing" -lm train_Only_Malay_norm.txt1.lm
			echo 'Order 1 ' >> y
			./ngram -lm train_Only_Malay_norm.txt1.lm -vocab cs_vocab -ppl test_norm_ngram_cut | awk 'FNR == 2 {print $6}' >> y 
			# ORDER 2
			./ngram-count -text train_Only_Malay_norm.txt -vocab cs_vocab -order 2   -addsmooth "$add_smoothing" -lm train_Only_Malay_norm.txt2.lm
			echo 'Order 2 ' >> y 
			./ngram -lm train_Only_Malay_norm.txt2.lm  -vocab cs_vocab -ppl test_norm_ngram_cut | awk 'FNR == 2 {print $6}' >> y
			
			# ORDER 3
			./ngram-count -text train_Only_Malay_norm.txt  -vocab cs_vocab -order 3   -addsmooth "$add_smoothing" -lm train_Only_Malay_norm.txt3.lm
			echo 'Order 3 ' >> y
			./ngram -lm train_Only_Malay_norm.txt3.lm -vocab cs_vocab  -ppl test_norm_ngram_cut | awk 'FNR == 2 {print $6}' >> y 
			
			
	else
		
		# INPUT ORDER 
		./ngram-count -text train_Only_Malay_norm.txt -order $order  -write train_Only_Malay_norm.txt.count
		./ngram-count -text train_Only_Malay_norm.txt -order $order  -addsmooth "$add_smoothing" -lm train_Only_Malay_norm.txt.lm
		echo "Order ${order}" >> 1
		./ngram -lm train_Only_Malay_norm.txt.lm  -ppl test_norm_ngram_cut | awk 'FNR == 2 {print $6}' >> 1 
	fi


	# ----- LINEAR INTERPOLATION -----

	if [ $linear12 -eq $var ]
		then
			./ngram-count -text train_Only_Malay_norm.txt -vocab cs_vocab -order 1   -addsmooth "$add_smoothing" -lm train_Only_Malay_norm.txt_order1.lm
			./ngram -lm train_Only_Malay_norm.txt_order1.lm  -vocab cs_vocab -ppl test_norm_ngram_cut -debug 2 > file1.ppl

			./ngram-count -text train_Only_Malay_norm.txt -vocab cs_vocab -order 2   -addsmooth "$add_smoothing" -lm train_Only_Malay_norm.txt_order2.lm
			./ngram -lm train_Only_Malay_norm.txt_order2.lm  -vocab cs_vocab -ppl test_norm_ngram_cut -debug 2 > file2.ppl

			lambda1=$(./compute-best-mix file1.ppl file2.ppl | awk '/best/{gsub(/\(|\)/,"");print $6}')

			./ngram -lm train_Only_Malay_norm.txt_order1.lm  -mix-lm train_Only_Malay_norm.txt_order2.lm -lambda $lambda1 -write-lm mixed.lm
			echo "Unigram-Bigram interpolation" >> y
			./ngram -lm mixed.lm -vocab cs_vocab  -ppl test_norm_ngram_cut | awk 'FNR == 2 {print $6}' >> y
	fi

	if [ $linear23 -eq $var ]
		then
			./ngram-count -text train_Only_Malay_norm.txt -vocab cs_vocab -order 2   -addsmooth "$add_smoothing" -lm train_Only_Malay_norm.txt_order2.lm
			./ngram -lm train_Only_Malay_norm.txt_order2.lm  -vocab cs_vocab -ppl test_norm_ngram_cut -debug 2 > file2.ppl

			./ngram-count -text train_Only_Malay_norm.txt -vocab cs_vocab -order 3   -addsmooth "$add_smoothing" -lm train_Only_Malay_norm.txt_order3.lm
			./ngram -lm train_Only_Malay_norm.txt_order3.lm  -vocab cs_vocab -ppl test_norm_ngram_cut -debug 2 > file3.ppl

			lambda2=$(./compute-best-mix file2.ppl file3.ppl | awk '/best/{gsub(/\(|\)/,"");print $6}')

			./ngram -lm train_Only_Malay_norm.txt_order2.lm  -mix-lm train_Only_Malay_norm.txt_order3.lm -lambda $lambda2 -write-lm mixed.lm
			echo "Bigram-Trigram interpolation" >> y
			./ngram -lm mixed.lm  -vocab cs_vocab -ppl test_norm_ngram_cut | awk 'FNR == 2 {print $6}' >> y
	fi
	echo "-----------------------------------" >> y
done


