# HackerBooks

This is a prototype of an ebook reader for iOS devices (adapted both to iPhone and iPad), made in Swift 3.

Every time the app starts, it loads a list of available books from a JSON file stored in the internal storage. In case it is the first time it is being executed, the JSON will be downloaded from <a href="https://t.co/K9ziV0z3SJ">this URL</a>.

The user can select a book from a catalogue to check the book details, read its content or add/remove the book from favorites. Every time the user attempts to read a book for the first time, a PDF document is downloaded and stored locally. When the user opens that book the next time, it will be loaded from the local storage instead of downloading it again. The same behavior happens with the pictures that are the cover of the books.

In order to show on an iPad device, the app uses a Split View Controller that slpits the screen into two parts:

* **Book List**: on the left, it is a Table View Controller showing the available books, grouped by categories. There is a special category, always at the begining of the list, that shows the books the user marked as favorites.

* **Book detail**: on the right, shown when the user selects a book on the left. It contains the information about the selected book (authors, categories, cover image) and a couple of buttons to read the contents and to add/remove it from favorites.

* **PDF Reader**: on the right too, shown when the user clicks the Read button on the Book detail view. A Web View Controller is used to show the book content.

In case of an iPhone device, each of these views are shown on different screens.

.
### Screenshots:

<kbd> <img alt="screenshot 1" src="https://cloud.githubusercontent.com/assets/18370149/25552229/a23b1860-2c94-11e7-957b-21f197e398b8.jpg" width="256"> </kbd> &nbsp; <kbd> <img alt="screenshot 2" src="https://cloud.githubusercontent.com/assets/18370149/25552230/a23b7f12-2c94-11e7-82a0-a0ea30ec462c.jpg" width="256"> </kbd> &nbsp; <kbd> <img alt="screenshot 3" src="https://cloud.githubusercontent.com/assets/18370149/25552268/2fd8c604-2c95-11e7-8f46-9f289e08689f.jpg" width="256"> </kbd>

&nbsp;
<kbd>
  <img alt="screenshot 4" src="https://cloud.githubusercontent.com/assets/18370149/25552299/26970d98-2c96-11e7-892b-1a4f2f2b1558.jpg" ></kbd>
  
&nbsp;
<kbd>
  <img alt="screenshot 5" src="https://cloud.githubusercontent.com/assets/18370149/25552300/26986ec2-2c96-11e7-976a-592d5f62bedf.jpg" ></kbd>

.
### Additional considerations:

While processing the JSON data file, in order to determine if the *NSJSONSerialization* class is returning a *Dictionary* object or an array of Dictionary objects, a cast is applied to the result of the JSONObjectWithData().

Both the PDF and the cover of the books are locally stored on the *Documents* folder of the app. Specifically, two sub-folders are created to cache these resources: /Images and /Pdf.

In order to keep the information about the favorite books of the user between executions, a notification is sent to the TableViewController every time a book changes its favorite status. Then, the updated model (including all the available books and the list of favorites) is serialized to a file Documents/books.json. This file has the same structure as the original downloaded file, but also includes a new field "favorite" (true/false) for each book.

Another approach, instead of using notifications, could be using the TableViewController as a delegate of the BookViewController that triggers the change in the favorite status of the book. One way or another, the TableViewController needs to be informed about the change, in order to store the data and refresh the list on screen.

To refresh the list of books, the *reloadData()* method is used. This will take the data from the TableView datasource and paint them on screen. This does not affect the performance in a significant way, since reloadData() actually refreshes only the visible rows of the list. Alternate choices could be the *reloadRows()* or *reloadSections()* methods.

If a PDF file is showing when the user selects another book in the list, the PDF viewer must show the new book contents. In order to achieve this, another notification is sent to the WebViewController that shows the PDFs. It gets the data about the selected book from the notification and updates the view.
