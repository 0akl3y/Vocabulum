<h1> Vocabulum </h1>
##Final Project of the Udacity iOS Nanodegree

Vocabulum is a vocabulary training app with an integrated dictionary. The dictionary uses the Yandex Dictionary API https://tech.yandex.com/dictionary/
for translation. The Yandex dictionary API supports several languages. Unfortunately not all languages are supported, but the user can also input custom languages and use the app without dictionary support.

##Book list overview

In Vocabulum, vocabulary can be organized in Books and Lessons. After opening Vocabulum, the Book List view lists all available Books and gives various options to edit, add an delete Books and Lessons. 

Users can add new Books via the "Add Book" button in the upper right corner. Lessons can be added via the page icon right from the book title. Lessons can be removed by either swiping from right to left, or by making the delete button available via the "Edit" button at the upper right side. Tapping the edit button also makes further options availalbe to edit title and description of an existing language.

##Organize books, lessons and languages

Every Book has a language pairing and a title assigned. Users can select and change the language pairing by tapping on the cells in the language section.

This will open a list of all Yandex supported languages. If the language combination already has a language selected, the language list will only show languages that are available for this selection. It is also possible to enter any language name via the "Select other Language" button. However, the Yandex dictionary feature will not be available in this case.

##Add Vocabulary

The vocabulary list of a lesson can be accessed from the Book List view by tapping on the "Vocabulary" button in a lesson's cell, or from the edit menu of a lesson. 

In the vocabulary list, new vocabulary entries can be added via the + button in the upper right side. Existing entries can be deleted by swipe or via the Edit button in the upper left corner. Entries can also be made editable by tapping on the respective row.

If Yandex supports the selected language combination a book icon will be available at each language input field. After entering a word the translation can be directly inserted into the respective field by tapping the book icon. The translation works in both directions.

Each vocabulary pair has also a difficulty setting which ranges from 1 (Known) to 4 (Hard). The default setting for newly entered vocabulary is hard. The difficulty will increase or decrease later depending on the frequency of correct answers. The entries in the vocabulary list are also organized in difficulty sections. This way the user can see, how familiar he is with the lesson's content.

##Learn Vocabulary

A learning session can be started from the Book List by tapping the Learn button at the right side of a lesson.
Before the session the user is asked to enter the number of words he wants to learn in this session. The current setting is persisted and will be automatically the default value until it is changed again. In learning mode, Vocabulum will pick the most difficult vocabulary first. If a word is answered correctly, the difficulty of the word is decreased by one or increased by one, if it is answered incorrectly. This way harder vocabulary will come more frequently.

