#!/usr/bin/perl
# 
# OpenPNE の日記を全部非公開に設定する
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
# 処理： 日記を一件ずつ開き非公開モードに設定して保存する
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

do{
	#現在ページURLを記憶しておく
	$url = $mech->uri();

	#次の一覧ページがあれば記憶しておく
	$nextpage = $mech->find_link( text => decode_utf8("次を表示"), url_regex => qr/page_fh_diary_list/ );

	#一覧より個別日記の編集URLを取得
	push (my @links, $mech->find_all_links(url_regex => qr/page_h_diary_edit/));
	
	#日記全部に処理
	foreach my $link (@links) {
		print "[INFO] diary URL (" . $link->url . ")\n";
		$mech->follow_link( url => $link->url );
		$mech->form_number(1);
		$mech->set_fields('public_flag'=>'private');
		$mech->submit;
		$mech->form_number(1);
		$mech->submit;
		$mech->get($url);
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

