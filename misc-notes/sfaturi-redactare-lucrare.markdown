Sfaturi generale pentru scrierea unui paper
===========================================

## Redactarea

* Citarea trebuie să fie pe același rând cu cuvântul dinainte, separată
  prin spațiu. LaTeX poate introduce linebreak acolo unde găsește
  spațiu, astfel că trebuie să folosiți `~` pentru a lega cuvântul și
  tag-ul `\cite` în același bloc, e.g. `Microkernel~\cite{lietdke}`. Nu
  știu cum/dacă se poate face asta în Word sau LibreOffice.
* Folosiți monospace (e.g. `\texttt` în LaTeX) pentru a reprezenta nume
  de funcții, nume de fișiere, căi în sistemul de fișiere, etc. În
  anumite cazuri o să fiți nevoiți să folosiți `\verb`, de exemplu
  pentru a evita problemele cu caractere speciale în LaTeX (`_`) și
  pentru a evita spargerea pe mai multe rânduri.
* Folosiți italic (e.g. `\textit` sau `\emph` în LaTeX) pentru cuvinte
  importante sau traduceri de cuvinte/expresii.
* Folosiți label-uri (în LaTeX) sau references (în Word/LibreOffice)
  pentru referirea secțiunilor, tabelelor, etc.  Mai multe detalii pe
  [WikiBooks][1].
* Conferințele și jurnalele impun de obicei limitări minime/maxime de
  spațiu pentru paper-uri (e.g. pentru multe conferințe limita maximă e
  de șase pagini). Aveți grijă să vă încadrați în limitele impuse.
* Folosiți cu încredere poze, diagrame arhitecturale, workflow diagrams,
  etc. pentru a descrie concepte, algoritmi, arhitecturi, etc. Folosiți
  label-uri pentru a identifica intern în LaTeX pozele și aveți grijă să
  le referiți și să le descrieți în text.
* Mare, mare atenție la typo-uri! Sunt considerate erori elementare.
* Recitiți atât secțiuni individuale, cât și paper-ul în ansamblu, după
  ce l-ați scris. Dacă lucrați în echipă, faceți peer review pe
  secțiunile pe care le-au scris colegii, ajută mai ales pentru a
  determina erorile în folosirea termenilor și inconsecvențele în firul
  de gândire per ansamblu al paper-ului.
* Folosiți citări pentru a referi alte paper-uri. Pentru LaTeX, puteți
  căuta paper-urile cu Google Scholar și obține direct citările în
  format BibTeX. De asemenea, puteți folosi platforme online precum
  [citeulike][2], [Mendeley][3] sau [Zotero][4].

## Structurarea logică

* Orice paper trebuie să înceapă cu următoarele patru puncte:
    * Contextul (localizare) -- care este starea curentă a domeniului,
      problematica largă, care sunt premisele fundamentale și cauzele de
      la care pleacă paper-ul.
    * Problema (focalizare) -- care este problema specifică pe care
      caută să o rezolve paper-ul.
    * Soluția (raportare) -- cum rezolvă paper-ul problema prezentată
      anterior, ideal o contribuție principală, eventual încă una-două
      contribuții secundare.
    * Evaluarea soluției (argumentare) -- argumentarea pe scurt (cu
      trimitere directă sau nu la secțiunea de evaluare) că paper-ul
      rezolvă problema și o parte din problematica largă a domeniului.

    Punctele de mai sus trebuie abordare pe scurt în abstract și
    elaborate în introducere. Ideal, prima iterație de redactare a
    paper-ului ar trebui să înceapă cu un abstract care să răspundă la
    întrebările astea, și abia apoi să treacă la elaborarea
    propriu-zisă.
* Secțiunile de tip „Background” au rolul de a descrie pe scurt
  conceptele pe care se bazează paper-ul, eventual cu trimitere la alte
  paper-uri.
* Secțiunile de tip „Related Work” au rolul de a prezenta alte abordări
  care încearcă să rezolve aceeași problemă (sau o parte din problemă,
  sau probleme foarte similare), și, dacă e posibil, poziționarea
  acestora față de contribuțiile paper-ului.
* Secțiunile de tip „Threat Model” sau „Usage Model” au rolul de a
  stabili presupuneri despre adversar/utilizator (de-aia apar mai ales
  în paper-urile de security) și limitări ale soluției (i.e. ce probleme
  *nu* sunt rezolvate).
* Secțiunea introductivă conține de obicei un sumar al contribuțiilor
  științifice (noi) descrise în articol.
* Secțiunea introductivă se încheie de obicei cu un paragraf care
  descrie foarte pe scurt fiecare secțiune în parte din cele rămase.
* Orice secțiune începe de obicei cu un paragraf care o sumarizează pe
  scurt, mai ales dacă nu reiese clar din titlul secțiunii ce se
  prezintă.

## Stilul

* Evitați exprimările colocviale și/sau bombastice, de genul „sheds
  light”, „tackle the problem”, „piece of software”, „solid
  management”. Keep it simple.
* Folosiți consecvent termeni specifici (e.g. „user space” versus
  „userspace”).
* Explicați termenii înainte de a-i folosi. Uneori o să fiți nevoiți să
  introduceți termeni noi în abstract sau introducere. Fie evitați asta
  cu totul prin reformulări, fie explicați în două cuvinte (la propriu)
  ce înseamnă termenul introdus.
* Folosiți explicații scurte, succinte. Nu introduceți în paper detalii
  irelevante pentru subiect (vedeți cele patru puncte de la structurarea
  logică). Alegeți un nivel minim de abstractizare și nu vă duceți sub
  el, altfel o să pierdeți cititorul.
* Atenție la timpii verbali folosiți. Design-ul, soluția, etc. sunt
  descrise la prezent, detaliile de implementare și evaluare sunt
  prezentate la trecut.
* Atât pentru a vă forma stilul cât și pentru a exersa înțelegerea
  problemei, citiți paper-uri din domeniu! Paper-urile sunt în general
  structurate pentru a fi înțelese doar din citirea abstractului, iar
  apoi pentru paper-urile mai relevante din introducere, design,
  evaluare, etc.

[1]: https://en.wikibooks.org/wiki/LaTeX/Labels_and_Cross-referencing
[2]: http://www.citeulike.org/
[3]: https://www.mendeley.com/
[4]: https://www.zotero.org/
