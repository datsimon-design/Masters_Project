
#let title = "Investigation spatial distribution."
#let authors       = [Simon Gendrisch#super[1 \*], Dr. Stephen Chan#super[1], Dr. Awantha Dissanyake#super[1] ]
#let affil-one     = "School of Marine and Environmental Science, University of Gibraltar, GX11 1AA"

#let corr-email    = "smes@unigib.edu.gi"
#let corr-author   = "Simon Gendrisch"
#let keywords      = "keyword1, keyword2, keyword3, keyword4, keyword5"
#let wordcount     = "XXXXX"


#page(header: none, footer: none, numbering: none)[
  #set text(font: "Libertinus Serif", size: 12pt)
  #set par(justify: false, leading: 0.6em)
  #set par(justify: false, leading: 0.6em)
  #show par: set par(leading: 0.6em, spacing: 0.9em)

  #align(center)[
    #text(size: 17pt, weight: "bold")[Supplemental Information:]

    #v(3em)

    #text(size: 15pt, weight: "bold")[#title]
  ]

  #v(1.4em)

  #text(weight: "bold")[#authors]

  #v(0.7em)
  #text(size: 9pt)[#super[1]#h(0.35em)#affil-one] 

  #v(0.9em)
  #text(weight: "bold")[\* Correspondence:] \
  #corr-author \
  #text()[#corr-email]

  #v(1.5em)
  #text(style: "italic")[Keywords: #keywords.]

  #v(1.5em)
  Word count (excluding References and Appendices): #text( weight: "bold")[#wordcount words]

  #pagebreak()
]

