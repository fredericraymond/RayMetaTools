#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# author:  	maxime déraspe
# email:	maxime@deraspe.net
# review:  	
# date:    	12-11-25
# version: 	0.01
# licence:  	

require 'bio'

class FastaParser               # Class FastaParser

  def initialize multifastafile	        # Hash = gene: line num
    @multifasta = multifastafile
    abort "File doesn't exist!! \n #{@usage}" unless File.exists?(@multifasta)
    lnum = 0
    @fastaH = Hash.new()
    f = File.open(@multifasta, "r") 
    f.each_line do |l|
      l.chomp!
      lnum += 1
      if l[0,1] == ">"
        gene = l[1..-1]
        @fastaH[gene] = lnum
        #puts "#{gene}\t#{@fastaH[gene].to_s}"
      end
    end
    f.close
  end


  def printGenes
    @fastaH.each_key do |k|
      puts k
    end
  end
  

  def getGene(name)

    curFasta = ""
    line = []
    regex = name.downcase.to_s
    @fastaH.each_key do |k|
      if k.downcase.to_s =~ /#{regex}/
        line.push(@fastaH[k].to_i)
      end
    end

    line.sort
    out = ""
    i=0
    c=-1
    inSeq = false

    f = File.open(@multifasta, "r")
    f.each_line do |l|
      i += 1
      if l[0] == ">"
        c += 1
        # if l.downcase.include? name.downcase
        # puts l =~ /regex/
        if l.downcase.to_s =~ /#{regex}/
          inSeq = true
          curFasta = "#{curFasta}#{l}"
        else
          inSeq = false
        end
      elsif i == line[c].to_i
        inSeq = true
        curFasta = "#{curFasta}#{l}"
      elsif inSeq
        curFasta = "#{curFasta}#{l}"
      end
    end

    return curFasta

  end    


  def split

    i=0
    file = File.open("#{i}.fasta","w")

    f = File.open(@multifasta, "r")
    f.each_line do |l|
      if l[0] == ">"
        i += 1
        file.close
        fName = l.split(" ")[0].gsub(">","")
        file = File.open("#{fName}.fasta","w")
        file.write(l.to_s)
      else
        file.write(l)
      end
    end
    
    file.close()
    File.delete("0.fasta")
    f.close()
 
  end
  


  def merge nspacer

    seq = ""
    spacer = "n" * nspacer
    flat = Bio::FlatFile.auto(@multifasta)
    
    gff = File.new("#{@multifasta}.merged.gff","w")
   
    pos = 1

    flat.each do |s|
      seq << "#{s.seq}#{spacer}"
      ftname = s.entry_id
      gff.write("#{@multifasta}\t.\tcontig\t#{pos}\t#{pos+s.seq.length}\t.\t+\t.\tID=#{ftname}\n")
      pos += (s.seq.length + nspacer)
    end

    gff.close
    flat.close

    bioseq = Bio::Sequence.new(seq)
    puts bioseq.output_fasta("#{@multifasta} merged with #{nspacer} n")
    
  end



  def lengthExtract len
    seq = ""
    bpcount = 0
    i=0
    outname = len.gsub(">","gt-").gsub("<","lt-")
    file = File.open("Contigs-#{outname}.fasta","w")

    f = File.open(@multifasta, "r")
    f.each_line do |l|
      if l[0] == ">" or f.eof?
        if len.include? ">"
          bpNb = len.gsub(">","")
          if bpcount > bpNb.to_i
            file.write(seq)
          end
        elsif len.include? "<"
          bpNb = len.gsub("<","")
          if bpcount < bpNb.to_i
            file.write(seq)
          end
        else
          abort "Symbol > of < not recognized"
        end
        bpcount = 0
        seq = ""
        seq << l
      else
        bpcount = bpcount + l.length - 1
        seq << l
      end
    end
    f.close
    file.close
  end                           # end lengthExtract


end                             # end of class FastaParser

