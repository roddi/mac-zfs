#!/usr/local/bin/perl
#
use File::Basename;
use Term::ANSIColor qw(:constants);
use Cwd;
use Cwd 'abs_path';
    
$Term::ANSIColor::AUTORESET = 1;
 
if (($#ARGV + 1) != 1){
    print("Usage: onnv_maczfs_chdiff.pl path/to/maczfs/repo\n");
    exit();
}

my $onnvRootDir = cwd(); 
my $maczfsRootDir = abs_path($ARGV[0]);

my @watched = (
                "^usr/src/cmd/zfs",
                "^usr/src/cmd/zpool",
                "^usr/src/cmd/ztest",
                "^usr/src/common/avl/",
                "^usr/src/common/nvpair/",
                "^usr/src/common/rpc/",
                "^usr/src/common/sys/",
                "^usr/src/common/util/",
                "^usr/src/common/zfs/",
                "^usr/src/head",
                "^usr/src/lib/libdevid/",
                "^usr/src/lib/libgen/",
                "^usr/src/lib/libnsl/",
                "^usr/src/lib/libnvpair",
                "^usr/src/lib/libuutil",
                "^usr/src/lib/libzfs",
                "^usr/src/uts/common/fs/zfs/",
                "^usr/src/uts/common/rpc/",
                "^usr/src/uts/common/os/"
               );
$count = 0;
print("Reading in diff lines...\n");
while (defined($line = <STDIN>)) {
    chop $line;
    if (substr($line,0,4) eq "diff"){
        #
        @hgLines[$count] = $line;
        if ($count % 1000 == 0){ print "$count\n"; }
        $count++;
    }
}

print("Diff Lines: $count - $#hgLines \n");
foreach $hgLine (@hgLines){
    @hgList = split(/ /, $hgLine);
    foreach $item (@watched){
        if (@hgList[$#hgList] =~ $item){
            print "onnv   :\t";
            print BLUE "$onnvRootDir/@hgList[$#hgList]\n";
            
            undef($finalFindResult);
            my ( $name, $path, $suffix ) = fileparse( @hgList[$#hgList], qr/\.[^.]*/ );
            my $rawFindResult = `find $maczfsRootDir -name "$name$suffix" -print`;
            my @findResult = split /\n/, $rawFindResult;
            my $maxFindPassesLeft = $#findResult;
            my $growingSearchPrefix = "";
            if ($#findResult == 0){
                        print "maczfs :\t";
                        print GREEN "$findResult[0]\n\n";
                        system("chdiff --wait $findResult[0] @hgList[$#hgList]");

            }
            if ($#findResult < 0){
                            print "maczfs :\t";
                            print RED "== No matching mac zfs file : $name$suffix \n\n";
            }
            if ($#findResult >= 1){
                print "maczfs :\t";
                print RED "== Multiple Matches: \n";
                    my $count = 0;
                    foreach my $match (@findResult) {
                        print "  [$count]  :\t";
                        print YELLOW "$match\n";
                        $count++;
                    }
                    print "\n";
#
#                        my ( $matchName, $matchPath, $matchSuffix ) = fileparse( $match, qr/\.[^.]*/ );
#                        my @splitList = split(/\//, $matchPath);
#                        my $toPrefix = $#splitList;
#                        my $growingSearchPrefix = "";
#
#                        my $matches = 0;
#                        while ( $matches != 1 ){
#                        
#                            if ( $toPrefix > 0 ){
#                                $growingSearchPrefix = $splitList[$toPrefix] . "/" . $growingSearchPrefix;
#                            }
#                            
#                            if (@hgList[$#hgList] =~ $growingSearchPrefix){
#                                $matches++;
#                            }
#                            $toPrefix--;
#                        }
#                    }
#                    
#                    if ($matches == 1){
#                        print "\t== Found single match using search string $growingSearchPrefix$name$suffix\n\n";
#                        $finalFindResult = $match;
#                    }
#                }
            }
        }
   }
}