Library Management System
A comprehensive MySQL database system designed to manage all aspects of a modern library's operations.

Project Description
The Library Management System is a relational database solution that helps libraries efficiently manage their collections, members, lending operations, and events. The system provides robust functionality to track books, manage memberships, process loans and returns, handle reservations, calculate fines, and organize library events.
Key Features

Member Management: Track member information, membership status, and activity.
Book Cataloging: Maintain a detailed catalog of books with support for multiple authors, categories, and publishers.
Inventory Control: Track individual book copies with statuses and conditions.
Loan Processing: Handle checkouts, returns, and renewals with appropriate business rules.
Reservation System: Allow members to reserve books that are currently unavailable.
Fine Management: Automatically calculate and track fines for overdue books.
Event Management: Organize and manage library events with member registration.
Reporting: Generate insights through pre-defined views for popular books, overdue loans, etc.

Database Structure
The system consists of several interconnected tables that form a comprehensive library management solution:

Core Entities: members, books, authors, publishers, categories, staff
Operational Tables: book_copies, loans, reservations, fines
Supporting Tables: book_authors (M), event_registrations (M)
Additional Features: events, reviews

Entity Relationship Diagram (ERD)
![library](https://github.com/user-attachments/assets/90d9011b-be9e-470f-a949-eccc02c23e53)


Prerequisites

MySQL Server 5.7+ 
MySQL Workbench or any SQL client (optional, for easier interaction)

Installation

Clone the repository:
git clone https://github.com/ChikaFranciscaChidimma/Library-Management-System-Database.git
cd Library-Management-System-Database

Import the database:
Using MySQL command line:
mysql -u ChikaFranciscaChidimma -p < Library-Management-System-Database.sql
OR using MySQL Workbench:

Open MySQL Workbench
Connect to your MySQL server
Go to Server > Data Import
Choose "Import from Self-Contained File" and select the SQL file
Start Import


Verify installation:
mysql -u ChikaFranciscaChidimma -p -e "USE library_management; SHOW TABLES;"


Database Usage Examples
Adding a new book with multiple authors:
sqlCALL sp_add_new_book(
  'The Great Novel', -- title
  '978-3-16-148410-0', -- ISBN
  '2023-01-15', -- publication date
  1, -- publisher_id
  2, -- category_id
  'English', -- language
  320, -- pages
  'A fascinating story about library science', -- description
  '1,3,4', -- author_ids (comma-separated)
  3, -- number of copies to add
  @new_book_id -- output variable
);

SELECT @new_book_id AS 'New Book ID';
Renewing a book loan:
sqlCALL sp_renew_loan(5, 1, @success, @message);
SELECT @success, @message;
View overdue books:
sqlSELECT * FROM vw_overdue_loans;
Customization
The database schema can be extended or modified to meet specific library requirements:

Add new fields to tables as needed
Create additional stored procedures for specific workflows
Design new views for custom reporting needs

Business Rules
The system enforces several business rules through constraints, triggers, and stored procedures:

Members cannot borrow books if they have unpaid fines
Books with reservations cannot be renewed
Members can renew a book up to 3 times
Fines are automatically calculated for overdue books
Book copy status is automatically updated when checked out or returned

License
Apache-2.0 license

Contact
chikafranciscachidimma@gmail.com
