#!/usr/bin/perl

use strict;
use warnings;
use Imager;
use bigint;
use GD;
use bytes;
use Image::Size;

my $imagem = new GD::Image('dilma.jpg') or die;
my ($width_x, $height_y) = imgsize("dilma.jpg");

my $img= Imager->new;
my $filename = "dilma.jpg";
$img->write( file=>$filename)
	or die "Cannot read: ", $img->errstr;

sub getBit{
	my $input = $_[0];
	my $bit = $_[1];
	
	$input = $input->as_hex;
	if(($input & (1<<$bit)) != 0){ return 1;}
	return 0;
}

sub translateChar{
	my $char = $_[0];
	my $inttochar = ord($char);
	if($inttochar >=65 and $inttochar <=90){
		return $inttochar-65;
	}
	if($inttochar >= 97 and $inttochar <=122){
                        return $inttochar-97;
        }
	if($inttochar == 32){return 26;} #space
        if($inttochar == 46){return 27;} #.
        if($inttochar == 44){return 28;} #,
        if($inttochar == 59){return 29;} #;
        if($inttochar == 63){return 30;} #?
        if($inttochar == 33){return 31;} #!
	
	print "Caracter Inválido: $char\n";
	return die;
}

sub translateInt{
	my $int = $_[0];

	if($int<=25){return chr($int+65);}
	elsif($int == 26){return chr(32);}
	elsif($int == 27){return chr(46);}
        elsif($int == 28){return chr(44);}
        elsif($int == 29){return chr(59);}
        elsif($int == 30){return chr(63);}
        elsif($int == 31){return chr(33);}

        else{print "Erro: Inteiro passou dos limites";return die;}
}


sub encodeData{
	my $data = $_[0];
	my $posX = $_[1];
	my $posY = $_[2];

	if($data>=32){print "Erro: Caracter inválido"; return die}
	
	my $rEnc = (&getBit($data,1) << 1) | &getBit($data,0);
        my $gEnc = &getBit($data,2);
        my $bEnc = (&getBit($data,4) << 1) | &getBit($data,3);
	
	my $index = $imagem->getPixel($posX,$posY);
	(my $r,my $g,my $b)=$imagem->rgb($index);

	$r = ((($r)&0xFF)>>2)<<2;
        $g = ((($g)&0xFF)>>1)<<1;
        $b = ((($b)&0xFF)>>2)<<2;

	my $newR = $r | $rEnc;
	my @arrayRGB = $newR;
        my $newG = $g | $gEnc;
	@arrayRGB = $newG;
        my $newB = $b | $bEnc;
	@arrayRGB = $newB;
	
	
	$imagem->setPixel($posX,$posY,@arrayRGB);
}
 
sub decodeData{
	my $posX = $_[0];
	my $posY = $_[1];

	my $index = $imagem->getPixel($posX,$posY);
        (my $r,my $g,my $b)=$imagem->rgb($index);

	$r = $r & 0xFF;
        $g = $g & 0xFF;
        $b = $b & 0xFF;

	my $rDec = (&getBit($r,1) << 1) | &getBit($r,0);
	my $gDec = &getBit($g,0);
	my $bDec = (&getBit($b,1)<<1) | &getBit($b,0);

	my $data = ($bDec << 3)|($gDec << 2)|$rDec;

	return $data;
}

sub writeChar{
	my $char = $_[0];
	my $posX = $_[1];
	my $posY = $_[2];

	my $i = &translateChar($char);
	if($i==-1) {return 0;}
	&encodeData($i,$posX,$posY);
	return 1;
}

sub readChar{
	my $posX = $_[0];
	my $posY = $_[1];

	return translateInt(decodeData($posX,$posY));
}

sub encodeMessage{
	my $message = $_[0]; #string é escalar!!!
#	print $message;
	if(bytes::length($message) + 5 >= $width_x * $height_y){print "Erro: Figura pequena para o texto, máximo ".$width_x * $height_y." caracteres para essa imagem."}

	my $salt = ",.!.,";
	my $string = $message . $salt;
	my @chars = split("",$string);
	my $posX=0; my $posY=0;
	my $pos=0;

	for(my $i=0; $i < (bytes::length($message)+5);$i++){
		if(&writeChar($chars[$i],$posX,$posY)){
			$posX++;
			print "Passei: ".$pos++;
			if($posX >= $width_x){$posX=0;$posY++; }
		}
	}
	
}

sub getMessage{

	my $string="";
	for(my $pos_y = 0 ; $pos_y< $height_y ; $pos_y++ ){
		for(my $pos_x=0; $pos_x<$width; $pos_x++){
			$string .= &readChar($pos_x,$pos_y);
			if
		}
	}
}
encodeMessage("junda");
