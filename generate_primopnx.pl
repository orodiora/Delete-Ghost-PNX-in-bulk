#! /m1/shared/bin/perl -w

##################
## Author: R. Orodio - Rachelle.Orodio@monash.edu
## Desc: This script generates Primo Normalized XMLs 
## that can be use for bulk deletion in Primo.
## This was created due to Primo issues of retaining ghost records, which have already been deleted in Voyager.
## Note these files are also Tar's and compressed into a single gzip file that can be harvested by Primo.
## Version: 1.0
##################

use strict;

## Specify the list of BIB Ids you wish to delete. One BIBId per line.
my $infile = "bibids.txt";

## Specify the directory where the PNX files will be created
my $outdir = "/export/directory/here/pnx";
my $grpcontents = 1000;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
my $strdate = sprintf("%4d-%01d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);

my $newyr = sprintf("%02d",$year+1900-2000);
my $newyear = sprintf("%02d",$year+1900);
my $newmonth = sprintf("%02d",$mon+1);
my $newday = sprintf("%02d",$mday);

my $newtime = sprintf("%02d%02d%02d",$hour,$min,$sec);
my $newhour = sprintf("%02d:%02d:%02d",$hour,$min,$sec);

my $newdate = "$newyr"."$newday"."$newmonth"."$newtime";

print "==============================================\n";
print "CREATING XML FILES FOR BULK DELETION FROM PRIMO \n";
print "Note: Each file contains 1000 xml's \n";
print "Processing Date : $newdate \n";

#### open PNX file
open(INFILE, "$infile") or die("Unable to open file");
my $create=0;
my $groupname=$outdir."/0";
my $cnt=0;
my $groupcnt=0;

while (<INFILE>)
{
        chomp;
        my @data = split(/\t/);
        my $line = $data[0];
        if ($create == 0) {
            mkdir($groupname, 0755);
         }
		 
		## This is the PNX Format 
        open(OUTFILE, ">>$groupname/primo.export.$newdate.$line.0.xml") or die("Cannot create output file $!\n");

        print OUTFILE "<?xml version=\"1.0\"  encoding=\"UTF-8\"?>\n";
        print OUTFILE "<OAI-PMH xmlns=\"http://www.openarchives.org/OAI/2.0/\"  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"  xsi:schemaLocation=\"http://www.openarchives.org/OAI/2.0/  http://www.
openarchives.org/OAI/2.0/OAI-PMH.xsd\">\n";


		##Ensure that the PNX Status is marked as deleted
        print OUTFILE "<ListRecords xmlns=\"\"><record><header status=\"deleted\"><identifier>$line</identifier>";
        print OUTFILE "<datestamp>".$newyear."-".$newday."-".$newmonth."T".$newhour."Z</datestamp></header><metadata></metadata></record></ListRecords>";
        print OUTFILE "</OAI-PMH>";
        close OUTFILE;
        if ($cnt<$grpcontents){
                $create=1;
                $cnt++;
        }
        else {
                $groupcnt++;
				$create=0;
                $cnt=0;
                $groupname=$outdir."/".$groupcnt;
        }
}

### Tar and gzip XML files
for (my $i=0;$i<=$groupcnt;$i++){
        my $tarfilename=$outdir."/primo.".$newdate.".".$i.".tar";
        my $tarsource=$outdir."/".$i;
        #print "tar -cf $tarfilename $tarsource\n";
        system("tar -cf $tarfilename $tarsource");
        system("gzip $tarfilename");
}
$groupcnt++;
print "Generated $groupcnt Files for PRIMO Deletion\n";
print "==============================================\n";
close INFILE;

