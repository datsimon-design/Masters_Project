#let doc_title = [$title$]
#let doc_authors = ($for(by-author)$[$it.name.literal$],$endfor$)
#let doc_date = [$date$]

#show: doc => article(
$if(title)$
  title: [$title$],
$endif$
$if(author)$
  author: [$author$],
$endif$
$if(keywords)$
  keywords: ($for(keywords)$"$keywords$",$endfor$),
$endif$

  // <-- restore your original author / affiliation argument lines here
  doc,
)