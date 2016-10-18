#!/bin/bash

ROOT_DIR=`pwd`
SITE_NAME='Code'
DOMAIN_NAME='basename $ROOT_DIR'

while getopts ":d:n:r:" opt; do
  case $opt in
    r)
      ROOT_DIR=$OPTARG
      ;;
    n)
      SITE_NAME=$OPTARG
      ;;
    d)
      DOMAIN=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


function header
{
	TITLE=$1
	cat << EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>$TITLE</title>

    <!-- Bootstrap -->
    <link href="/css/bootstrap.min.css" rel="stylesheet">
    <link href="/css/bootstrap-thema.min.css" rel="stylesheet">
    <link href="/css/highlight-default.css" rel="stylesheet">

  </head>
  <body>


<nav class="navbar navbar-default">
  <div class="container-fluid">
    <div class="navbar-header">
      <a class="navbar-brand" href="/">$SITE_NAME</a>
    </div>
    <div class="collapse navbar-collapse"> <p class="navbar-text">$TITLE</p></div>
  </div>
</nav>

EOF

}


function footer
{
	cat << EOF
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="/js/jquery-3.1.1.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="/js/bootstrap.min.js"></script>
    
    <script src="/js/highlight.pack.js"></script>
    <script>hljs.initHighlightingOnLoad();</script>
  </body>
</html>
EOF
}



function rootIndex
{
    header $SITE_NAME
    
    cat << EOF
    <ol class="breadcrumb">
  		<li class="active">$SITE_NAME</li>
	</ol>
EOF

	if	[ -f $ROOT_DIR/README ]; then
		cat << EOF
<div class="panel panel-default">
  <div class="panel-body">
EOF
    	cat $ROOT_DIR/README
		cat << EOF
  </div>
</div>
EOF
	fi
	
    cat << EOF
<table class="table"><tr><th>Repository</th><th>User</th><th>Date</th><th>Summary</th><th>Tag</th></tr>
EOF
    for repo in $ROOT_DIR/*; do
	name=`basename $repo`
	if [ ! -d $repo/.hg ]; then
	    continue;
	    
	fi
	hg log -l 1 -R $repo --template '<tr><td><a href="./'$name'">'$name'</a></td><td>{author}</td><td>{date|isodate}</td><td>{desc}</td><td>{tags}</td></tr>'
    

    done
    echo "</table>"
    footer
}




function folderContent
{
	local project=$1
	local name=$2
	local dir=$ROOT_DIR/$project/raw/$name
	local path
	if [ $name == '.' ]; then
	    title="source"
	else
	    title=`basename $name`
	fi
	
    header $title
    
    cat << EOF
    <ol class="breadcrumb">
  		<li><a href="/$project/">$project</a></li>
  		<li><a href="/$project/src">source</a></li>
EOF
    href=
    for path in `pathSegments $name`; do
	href=$href$path/
	cat << EOF
	    <li class="active"><a href="/$project/src/$href">$path</a></li>
EOF
    done
    cat << EOF
	</ol>
EOF

	cat << EOF
<ul class="nav nav-tabs">
  <li role="presentation" class="active"><a href="./">Content</a></li>
  <li role="presentation"><a href="./history.html">History</a></li>
</ul>
EOF


	
    cat << EOF
<table class="table"><tr><th>Name</th><th>User</th><th>Date</th><th>Summary</th><th>Tag</th></tr>
EOF
	local f
	for f in `ls -1 --group-directories-first $dir`; do
		if	[ -f $dir/$f ]; then
			link="$f-content.html"
		fi
		if	[ -d $dir/$f ]; then
			link="$f/"
		fi
		
		echo "<tr><td><a href="$link">$f</a></td>"
		hg log -l 1 -R $ROOT_DIR/$project/raw --template '<td>{author}</td><td>{date|isodate}</td><td>{desc}</td><td>{tags}</td></tr>' $dir/$f
	done
    echo "</table>"

	# Show README-File
	if	[ -f $dir/README ]; then
		cat << EOF
<div class="panel panel-default">
  <div class="panel-body">
EOF
    	cat $dir/README
		cat << EOF
  </div>
</div>
EOF
	fi
    
    footer
}




function folderHistory
{
	local project=$1
	local name=$2
	local dir=$ROOT_DIR/$project/raw/$name
	local path

	if [ $name == '.' ]; then
	    title="source"
	else
	    title=`basename $name`
	fi
	
    header $title
    
    cat << EOF
    <ol class="breadcrumb">
  		<li><a href="/$project/">$project</a></li>
  		<li><a href="/$project/src">source</a></li>
EOF
    href=
    for path in `pathSegments $name`; do
	href=$href$path/
	cat << EOF
	    <li class="active"><a href="/$project/src/$href">$path</a></li>
EOF
    done
    cat << EOF
	</ol>
EOF

cat << EOF
<ul class="nav nav-tabs">
  <li role="presentation"><a href="./">Content</a></li>
  <li role="presentation" class="active"><a href="">History</a></li>
</ul>
EOF

	if	[ -f $dir/README ]; then
		cat << EOF
<div class="panel panel-default">
  <div class="panel-body">
EOF
    	cat $dir/README
		cat << EOF
  </div>
</div>
EOF
	fi
	
    cat << EOF
<table class="table"><tr><th>Commit</th><th>User</th><th>Date</th><th>Summary</th><th>Tag</th></tr>
EOF
	hg log -R $ROOT_DIR/$project/raw --template '<tr><td><a href="/'$project'/commit/{node}.html">{node|short}</a></td><td>{author}</td><td>{date|isodate}</td><td>{desc}</td><td>{tags}</td></tr>' $dir
    echo "</table>"
    
    footer
}


function fileContent
{

    local project=$1
    local name=$2
    local file=$ROOT_DIR/$project/raw/$name
    local path

    header `basename $name`

    cat << EOF
    <ol class="breadcrumb">
  		<li><a href="/$project/">$project</a></li>
  		<li><a href="/$project/src">source</a></li>
EOF
    href=
    for path in `pathSegments $name`; do
	href=$href$path/
	cat << EOF
	    <li class="active"><a href="/$project/src/$href">$path</a></li>
EOF
    done
    cat << EOF
	</ol>
EOF


    cat << EOF
<ul class="nav nav-tabs">
  <li role="presentation" class="active"><a href="`basename $name`-content.html">Content</a></li>
  <li role="presentation"><a href="`basename $name`-history.html">History</a></li>
  <li role="presentation"><a href="/$project/raw/$name">Raw</a></li>
</ul>
EOF

    echo "<pre><code>"

    # html-encode
    cat $file|sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
    echo "</code></pre>"

    footer
}


function fileHistory
{
	local project=$1
	local name=$2
	local file=$ROOT_DIR/$project/raw/$name
	local path
	
    header `basename $name`


    cat << EOF
    <ol class="breadcrumb">
  		<li><a href="/$project/">$project</a></li>
  		<li><a href="/$project/src">source</a></li>
EOF
    href=
    for path in `pathSegments $name`; do
	href=$href$path/
	cat << EOF
	    <li class="active"><a href="/$project/src/$href">$path</a></li>
EOF
    done
    cat << EOF
	</ol>
EOF
    

cat << EOF
<ul class="nav nav-tabs">
  <li role="presentation"><a href="`basename $name`-content.html">Content</a></li>
  <li role="presentation" class="active"><a href="`basename $name`-history.html">History</a></li>
  <li role="presentation"><a href="/$project/raw/$name">Raw</a></li>
</ul>
EOF

	
    cat << EOF
<table class="table"><tr><th>Commit</th><th>User</th><th>Date</th><th>Summary</th><th>Tag</th></tr>
EOF
	hg log -R $ROOT_DIR/$project/raw --template '<tr><td><a href="/'$project'/commit/{node}.html">{node|short}</a></td><td>{author}</td><td>{date|isodate}</td><td>{desc}</td><td>{tags}</td></tr>' $file
    echo "</table>"
    
    footer
}




function pathSegments
{
    filename=$1

    for path in `dirname $filename|tr "/" "\n"`; do
	if	[ $path == "." ]; then
	    continue;
	fi
	echo $path
    done
}


# commit
# param 1: project name
# param 2: commit hash
function commit
{
	local project=$1
	local dir=$ROOT_DIR/$project
	local commit=$2
	
    header $name
    
    cat << EOF
    <ol class="breadcrumb">
  		<li><a href="../">$project</a></li>
  		<li class="active">Commit $commit</li>
	</ol>
EOF

	
    cat << EOF
EOF
	echo "<pre><code>"
	hg log -r $commit -p -R $dir
	echo "</code></pre>"
    
    footer
}



function projectSummary
{
    project=$1
    header $project

    cat << EOF
    <ol class="breadcrumb">
  		<li class="active">$project</li>
	</ol>
EOF
    
cat << EOF

<div class="well">Clone this repository with <code>hg clone http://$DOMAIN/$project</code></div>
<ul class="nav nav-pills nav-stacked">
<li role="presentation"><a href="/$project/$project.tar.gz">Download Tarball</a></li>
<li role="presentation"><a href="/$project/changelog.txt">Changelog</a></li>
<li role="presentation"><a href="/$project/src/">Source</a></li>
</li>
EOF

	if	[ -f $ROOT_DIR/$project/raw/README ]; then
		cat << EOF
<div class="panel panel-default">
  <div class="panel-body">
EOF
    	cat $ROOT_DIR/$project/raw/README
		cat << EOF
  </div>
</div>
EOF
	fi

    footer
}


# Create all Project files
# param 1: project name
function project
{
    local name=$1
    local dir=$ROOT_DIR/$name

    if	[ -f $dir/$name.tar.gz ]; then
        if	[ `hg log -R $dir -l 1 --template '{date(date,"%s")}'` -lt `stat -c "%Y" $dir/$name.tar.gz ` ]; then
	    echo "$name is actual"
	    continue;
	fi
    fi


    rm -rf $dir/raw
    mkdir -p $dir/raw

    rm -rf $dir/src
    mkdir $dir/src

    hg clone -q $dir $dir/raw



    projectSummary $name > $dir/index.html

    for f in `cd $dir/raw && find . -type d ! -path "*/.hg*"`; do

        mkdir -p $dir/src/$f
	folderContent $name $f > $dir/src/$f/index.html
	folderHistory $name $f > $dir/src/$f/history.html
    done

    for f in `cd $dir/raw && find . -type f ! -path "*/.hg*"`; do
	fileContent $name $f > $dir/src/$f-content.html
	fileHistory $name $f > $dir/src/$f-history.html
    done


    #rm -rf $dir/commit
    mkdir -p $dir/commit
    for c in `hg log -R $dir --template '{node}\n'`; do
	if [ ! -f $dir/commit/$c.html ]; then
	    commit $name $c > $dir/commit/$c.html
	fi
    done

    # Clean .hg
    rm -rf $dir/raw/.hg

    # create static archive (without .hg)
    `cd $dir/raw && tar cfz ../$name.tar.gz *`
    hg -R $dir log --style changelog > $dir/changelog.txt
}




# Create start page with all projects
rootIndex > $ROOT_DIR/index.html


rm $ROOT_DIR/.htaccess
echo "# generated" > $ROOT_DIR/.htaccess

# Loop over all projects
for f in $ROOT_DIR/*; do

	project=`basename $f`
	
    # is this a Mercurial archive?
    if [ ! -d $f/.hg ]; then
		continue;
    fi

    # Serve the RAW files as text/plain (not all, images should stay images)
    echo "AddType text/plain .java .php .txt .xml .json" > $ROOT_DIR/$project/raw/.htaccess

    name=`basename $f`

    # Call the project
    project $name

done

