#!/usr/bin/perl
# 
# OpenPNE の日記を全部ローカルに保存する
# 
# 引数1: --username=<username>
# 引数2: --password=<password>
# 引数3: --url=<url>
# 
# 引数3個は全て必須。ログイン用のID、ログイン用のPW、トップページのURL、を指定する
# 
# 例:
# 
# perl ./openpne.diary.save.pl --username=user@example.com --password=password --url=http://openpne.example.com/
# 
# 出力： 日記1件につき1ファイル生成、ファイル名はカレントディレクトリの d_日記ID.html
# 

use utf8;
use Encode;
use open ':utf8';
use WWW::Mechanize;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use strict;

my $username='';
my $password='';
my $url = '';

GetOptions('username=s' => \$username, 'password=s' => \$password, 'url=s' => \$url );

if( ($username eq '' ) or ( $password eq '' ) or ( $url eq '' ) ){
	print "usage:\n";
	print "perl $0 --username=<username>  --password=<password> --url=<url>\n";
	exit;
}

my $mech = WWW::Mechanize->new();
$mech->get($url);

if( $mech->success() && $mech->is_html() ){
    print "[SUCCESS] get login page \n";
}else{
    print "[FAILURE] get login page \n";    exit;
}

print "[INFO] login start \n";
my $r = $mech->submit_form(
    form_name=>'login',
    fields => {
        username => $username,
        password => $password,
    },
    );

if ($mech->success()){
    print "[SUCCESS] login ok \n";
}else{
    print "[FAILURE] login fail \n";    exit;
}

$url = $url . '?m=pc&a=page_fh_diary_list';
$mech->get($url);

my $nextpage='';
my $nextcheck=1;
my $filename1;
my $filename2;

do{
	#次の一覧ページがあれば記憶しておく
	$nextpage = $mech->find_link( text => decode_utf8("次を表示"), url_regex => qr/page_fh_diary_list/ );

	#一覧より個別日記URLを取得
	push (my @links, $mech->find_all_links(url_regex => qr/target_c_diary_id=[0-9]+$/));
	
	#日記全部に処理
	foreach my $link (@links) {
		print "[INFO] diary URL (" . $link->url . ")\n";
		$link->url  =~ /=([0-9]+)$/;
		$filename1 = 'd_'.$1.'.html';
		$filename2 = 'd_'.$1.'.txt';
		$mech->follow_link( url => $link->url );
		open (FILE, "> $filename1");
		print FILE $mech->content;
		close(FILE);
		#open (FILE, "> $filename2");
		#print FILE $mech->content(format => "text");
		#close(FILE);
	}
	
	if( $nextpage ){
		print "[INFO] NEXT URL: " . $nextpage->[0] . "\n";
		$mech->get($nextpage->[0]);
	}else{
		$nextcheck=0;
		print "[INFO] END. \n";
	}
}while( $nextcheck );

exit;

