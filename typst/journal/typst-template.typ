#import "@preview/wordometer:0.1.5": word-count, total-words

#let article(
  title: none,
  author: none,
  keywords: none,
  sectionnumbering:none,
  body,
) = {
  set document(title: title, author: "Simon Gendrisch", keywords: keywords)
  page(paper: "a4", footer: none)[
    #set text(font: "Source Sans 3", size: 14pt)
    #set par(justify: false, leading: 0.6em)
   #align(center)[
    #text(size: 22pt, weight: "bold")[#title]

    #v(2em)

    #text(size: 14pt)[by]

    #v(2em)

    #text(size: 16pt, weight: "bold")[#author]

    #v(3em)

    #text(style: "italic", size: 14pt, top-edge: 1em, bottom-edge: -0.5em)[Research Project submitted to the University of Gibraltar\ in partial fulfilment of the requirements for the degree of]

    #v(2em)

    #text(weight: "bold")[MSc in Marine Science and Climate Change]

    #v(2em)

    #image("/typst/journal/Logo-Red-Crest-Side.png", width: 70%)

    #v(10em)

    #datetime.today().display("[month]/[year]")

  ]

  #pagebreak()

  #grid(
  columns: (6cm, 1fr),
  column-gutter: 3cm,
  row-gutter: 2em,

  [Student name:], [
    *Simon Gendrisch* \
    University of Gibraltar
  ],

  [Primary Supervisor:], [
    *Dr. Stephen Chan* \
    University of Gibraltar
  ],

  [Secondary Supervisor:], [
    *Dr. Awantha Dissanayake* \
    University of Gibraltar
  ],
  )

  #pagebreak()

  #text(weight: "bold")[MSc Research Project licence 

  This work has been deposited in the University of Gibraltar Parasol Library and Institutional Repository in line with University Regulations.  

  Use of this work is licensed under a Creative Commons Attribution-Non commercial-No derivatives 4.0 International Licence (CC-BY-NC-ND).
  ]

  #v(5em)

  Word count (excluding References and Appendices): #text( weight: "bold")[#total-words words]

  #pagebreak()


  #text(weight: "bold")[MSc Research Project declaration form]

  #text(size: 12pt)[The following declaration is required when submitting your MSc Research Project under the University's regulations.]

  #text(style: "italic", size:12pt)[I hereby declare that my Research Project entitled:] \ 
  #text(size: 12pt)[#title]

  #v(2em)

  #set list(indent: 3em)

  #text(size:11pt)[- Is the result of my own work and includes nothing which is the outcome of work performed in collaboration except as declared in the Preface and specified in the text

  - is not substantially or wholly the same as any work that I have submitted, or, is being concurrently submitted for a degree or diploma or other qualification at the University of Gibraltar or any other University or similar institution except as declared in the Preface and specified in the text. 

  - Does not exceed the prescribed word limit ]

  #v(2em)

  #text(size: 12pt)[Print Name: #author]

  #text(size: 12pt)[Signature: #image("/typst/Unterschrift.png", width: 20%)]

  #text(size:12pt)[Date: #datetime.today().display("[day]/[month]/[year]")]

  #align(right)[#image("/typst/journal/Logo-Red-Crest-Side.png", width: 35%)]

  #pagebreak()

  
  ]

  //Rest of article styling
  set page(
    paper: "a4",
    margin: (
      x: 2.5cm,
      y: 2.5cm,
    )
  )
  
  set text(
    font: "Libertinus Serif",
    size: 12pt,
    top-edge: 1em,
  )
  
  set par(
    spacing: 1.5em,
    justify: true,
    leading: 0.75em
  )

  set heading(numbering: sectionnumbering)

  [
  // now add everything from the sup material page

  #align(center)[#text(weight: "bold", size: 15pt)[#title]]

  #v(1.4em)

  #text(weight: "bold")[#author#super[1], Dr. Stephen Chan#super[1], Dr. Awantha Dissanyake#super[1] ]

  #v(0.1em)
  #text(size: 9pt)[#super[1]#h(0.35em)School of Marine and Environmental Science, University of Gibraltar, GX11 1AA] 

  #v(1.5em)
  #text(weight: "bold")[\*Correspondence:] \
  #author \
  #text()[SMES\@unigib.edu.gi]

  #v(1.5em)
  #text(style: "italic")[Keywords: #keywords.join(", ")]
  ]
  


  show figure.caption: it => context{
    let head = it.supplement + [ ] + it.counter.display(it.numbering) + [.]

      set align(left)
      set par(justify: false)

      block(width: 100%, grid(
        columns: (2.5cm, 1fr),          // <-- 2.5cm IS the "Space"; change to your tab stop
        column-gutter: 0pt,
        align: (left + top, left + top),
        head,
        it.body,
      ))
  }

  show: word-count.with(exclude: <no-wc>)

  show figure.caption: set text(font: "Source Sans 3", size : 9pt)

  show figure.where(kind: table): set figure.caption(position: top)
  //show figure.where(kind: table): set align(center)

  show figure.where(kind: image): set figure.caption(position: bottom)

  show figure.where(kind: "quarto-float-app"): set block(breakable: true)
  show figure.where(kind: "quarto-float-app"): set align(left)


  //Add the S prefix to fig and table, remove for journal article
  

  show table: it => {
  set text(size: 9pt)
  set par(leading: 0.65em, spacing: 0.65em)
  it
  }
  set table(
  stroke: (x, y) => (
    top: if y == 0 { 0.7pt }        // rule above the header
         else if y == 1 { 0.4pt }   // rule below the header
         else { 0pt },              // no inter-row lines
  ),
)

  body
}

  

  