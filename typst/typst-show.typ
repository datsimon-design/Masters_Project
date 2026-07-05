#show: doc => article(
$if(title)$
  title: [$title$],
$endif$
$if(author)$
  author: [$author$],
$endif$
$if(institution)$
  institution: [$institution$],
$endif$
$if(keywords)$
  keywords: [$keywords$],
$endif$
$if(supervisor)$
  supervisor: [$supervisor$],
$endif$
$if(ssupervisor)$
  ssupervisor: [$ssupervisor$],
$endif$
$if(date)$
  date: [$date$],
$endif$
  // <-- restore your original author / affiliation argument lines here
  doc,
)