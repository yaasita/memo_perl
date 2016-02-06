#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use File::Basename qw/basename dirname/;
use MIME::Base64 qw/encode_base64/;

use Encode;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $q = new CGI;
print $q->header( -charset => "utf-8", );

my $detail = decode("UTF-8",$q->param('detail'));
if (defined $detail){
    open (my $wr,">>:utf8", "/path/to/memo") or die $!;
    print $wr time() . "," . encode_base64(encode("UTF-8",$detail));
    close $wr;
}
else {
    $detail = "";
}

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
        </style>
    </head>
    <body>
        <a href="/@{[basename $0]}"><h1>Memo</h1></a>
        <div>
        @{[$detail]}
        </div>
        <form method="post" action="@{[basename $0]}" class="pure-form">
            <textarea name="detail" class="pure-input-1-2"></textarea><br><br>
            <input type="submit" class="pure-button" value="memo">
        </form>
    </body>
</html>
HTML
