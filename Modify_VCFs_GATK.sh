mkdir -p mod/vcf_mod

#fetch the consolidated list of contig headers to remove/add from the list of VCFs
grep "contig=" *vcf | cut -d':' -f2 | sed 's/^.*ID=\|,length.*//g' | sort -uVk1 > all.chrs.txt

#contig list to remove from the vcf 
grep decoy all.chrs.txt >> to_remove.heads
grep _alt all.chrs.txt >> to_remove.heads
grep HLA all.chrs.txt >> to_remove.heads
grep EBV all.chrs.txt >> to_remove.heads

#fetch the remaining chromosome/contigs/sequence features from the VCFs
for i in *vcf; do echo "grep -Fvf to_remove.heads "$i" > mod/"$i""; done | parallel -j4
cd mod

#used sed to fix the remaining sequence identifiers. the sed group essentially relabels the identifiers
for i in *vcf; do sed 's/chr[0-9][0-9]_\|v[0-9]_random\|chrUn_\|v[0-9]\|chr[A-Z]_\|chr[0-9]_//g' "$i" | tail -n+2 | sed '1i##fileformat=VCFv4.1' > vcf_mod
/"$i"; done
cd vcf_mod

#fix the vcf headers so that haplotype caller doesn't complain
for i in *vcf; do gatk FixVcfHeader -I "$i" -O "$i".gz; done
