#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use File::Basename qw/basename dirname/;
use MIME::Base64 qw/encode_base64 decode_base64/;
use feature qw(say);
use Time::Piece;

use Encode;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $DATA_FILE = "/path/to/memo";

my $q = new CGI;
print $q->header( -charset => "utf-8", );

# 追加
my $detail = decode("UTF-8",$q->param('detail'));
if (defined $detail){
    open (my $wr,">>:utf8", $DATA_FILE) or die $!;
    print $wr time() . "," . encode_base64(encode("UTF-8",$detail));
    close $wr;
}
else {
    $detail = "";
}
# 削除
if (defined $q->param("del")){
    my %list;
    open (my $in,"<",$DATA_FILE) or die $!;
    while (<$in>){
        chomp;
        my ($time,$body) = split(/,/);
        $list{$time} = $body;
    }
    close $in;
    my @del = $q->param("del");
    for(@del){
        delete($list{$_});
    }
    open (my $wr,">", $DATA_FILE) or die $!;
    for ( sort keys(%list) ){
        print $wr $_ . "," . $list{$_} . "\n";
    }
    close $wr;
}

# 一覧
my %list;
{
    open (my $in,"<", $DATA_FILE) or die $!;
    while (<$in>){
        chomp;
        my ($time,$body) = split(/,/);
        $list{$time} = $body;
    }
    close $in;
}

my @tag = map { 
    my $key = $_;
    my $t = localtime($key);
    "<tr>\n" .
    "  <td>" . $t->strftime("%Y/%m/%d %H:%M:%S") . "</td>\n" .
    "  <td>" . decode("UTF-8",decode_base64($list{$key})) . "</td>\n" .
    "  <td>" . qq/<input name="del" value="$key" type="checkbox">/ . "</td>\n" .
    "</tr>\n";

} sort (keys %list);
#
#print for @tag;
#
#__DATA__

print <<"HTML";
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Memo</title>
        <link rel="stylesheet" href="//cdn.jsdelivr.net/pure/0.6.0/pure-min.css">
        <style>
        body {  
            width:800px;
            text-align: center;
            margin-right: auto;
            margin-left : auto;
        }  
        table {
        width:800px
        }
        </style>
    </head>
    <body>
        <a href="/memo"><h1>Memo</h1></a>
        <div>
            @{[$detail]}
        </div>
        <form method="post" action="@{[basename $0]}" class="pure-form">
            <textarea name="detail" class="pure-input-1-2"></textarea><br><br>
            <input type="submit" class="pure-button" value="memo">
        </form>
        <hr>
        <form method="post" action="@{[basename $0]}">
            <table class="pure-table pure-table-bordered">
                <thead>
                    <tr>
                        <th>time</th>
                        <th>detail</th>
                        <th>del</th>
                    </tr>
                </thead>
                @tag
            </table>
            <br>
            <input type="submit" value="delete" class="pure-button">
        </form>
    </body>
</html>
HTML
