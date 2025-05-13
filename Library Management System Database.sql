-- Library Management System Database
-- A comprehensive database for managing library operations

-- Drop database if it exists to start fresh
DROP DATABASE IF EXISTS library_management;

-- Create the database
CREATE DATABASE library_management;

-- Use the database
USE library_management;

-- -----------------------------------------------------
-- Table `members`
-- Stores information about library members/patrons
-- -----------------------------------------------------
CREATE TABLE `members` (
  `member_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `phone_number` VARCHAR(20) NULL,
  `address` VARCHAR(255) NULL,
  `date_of_birth` DATE NULL,
  `membership_date` DATE NOT NULL DEFAULT (CURRENT_DATE),
  `membership_expiry` DATE NOT NULL,
  `membership_status` ENUM('Active', 'Expired', 'Suspended') NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`member_id`),
  INDEX `idx_member_email` (`email`),
  INDEX `idx_member_status` (`membership_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores library member information';

-- -----------------------------------------------------
-- Table `staff`
-- Stores information about library employees
-- -----------------------------------------------------
CREATE TABLE `staff` (
  `staff_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `phone_number` VARCHAR(20) NULL,
  `position` VARCHAR(50) NOT NULL,
  `hire_date` DATE NOT NULL,
  `is_admin` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`staff_id`),
  INDEX `idx_staff_position` (`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores library staff information';

-- -----------------------------------------------------
-- Table `publishers`
-- -----------------------------------------------------
CREATE TABLE `publishers` (
  `publisher_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `address` VARCHAR(255) NULL,
  `phone` VARCHAR(20) NULL,
  `email` VARCHAR(100) NULL,
  `website` VARCHAR(255) NULL,
  PRIMARY KEY (`publisher_id`),
  UNIQUE INDEX `idx_publisher_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores book publisher information';

-- -----------------------------------------------------
-- Table `authors`
-- -----------------------------------------------------
CREATE TABLE `authors` (
  `author_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `biography` TEXT NULL,
  `birth_date` DATE NULL,
  `death_date` DATE NULL,
  PRIMARY KEY (`author_id`),
  INDEX `idx_author_name` (`last_name`, `first_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores author information';

-- -----------------------------------------------------
-- Table `categories`
-- Book categories/genres 
-- -----------------------------------------------------
CREATE TABLE `categories` (
  `category_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `description` TEXT NULL,
  `parent_category_id` INT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE INDEX `idx_category_name` (`name`),
  CONSTRAINT `fk_category_parent`
    FOREIGN KEY (`parent_category_id`)
    REFERENCES `categories` (`category_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores book categories/genres';

-- -----------------------------------------------------
-- Table `books`
-- Main book information table
-- -----------------------------------------------------
CREATE TABLE `books` (
  `book_id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `isbn` VARCHAR(20) UNIQUE NULL,
  `publication_date` DATE NULL,
  `publisher_id` INT NULL,
  `category_id` INT NULL,
  `language` VARCHAR(50) DEFAULT 'English',
  `pages` INT NULL,
  `description` TEXT NULL,
  `added_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`book_id`),
  INDEX `idx_book_title` (`title`),
  INDEX `idx_book_isbn` (`isbn`),
  INDEX `fk_book_publisher_idx` (`publisher_id`),
  INDEX `fk_book_category_idx` (`category_id`),
  CONSTRAINT `fk_book_publisher`
    FOREIGN KEY (`publisher_id`)
    REFERENCES `publishers` (`publisher_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_book_category`
    FOREIGN KEY (`category_id`)
    REFERENCES `categories` (`category_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores main book information';

-- -----------------------------------------------------
-- Table `book_authors`
-- Many-to-Many relationship between books and authors
-- -----------------------------------------------------
CREATE TABLE `book_authors` (
  `book_id` INT NOT NULL,
  `author_id` INT NOT NULL,
  `author_role` VARCHAR(50) DEFAULT 'Author',
  PRIMARY KEY (`book_id`, `author_id`),
  INDEX `fk_book_authors_author_idx` (`author_id`),
  CONSTRAINT `fk_book_authors_book`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`book_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_book_authors_author`
    FOREIGN KEY (`author_id`)
    REFERENCES `authors` (`author_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Links books with their authors';

-- -----------------------------------------------------
-- Table `book_copies`
-- Individual physical copies of books
-- -----------------------------------------------------
CREATE TABLE `book_copies` (
  `copy_id` INT NOT NULL AUTO_INCREMENT,
  `book_id` INT NOT NULL,
  `barcode` VARCHAR(50) UNIQUE NOT NULL,
  `format` ENUM('Hardcover', 'Paperback', 'Audiobook', 'E-book', 'Other') NOT NULL DEFAULT 'Hardcover',
  `acquisition_date` DATE NOT NULL,
  `cost` DECIMAL(10,2) NULL,
  `condition` ENUM('New', 'Good', 'Fair', 'Poor', 'Damaged') NOT NULL DEFAULT 'New',
  `status` ENUM('Available', 'On Loan', 'Reserved', 'In Processing', 'Lost', 'Damaged') NOT NULL DEFAULT 'In Processing',
  `shelf_location` VARCHAR(50) NULL,
  PRIMARY KEY (`copy_id`),
  INDEX `idx_copy_barcode` (`barcode`),
  INDEX `idx_copy_status` (`status`),
  INDEX `fk_copy_book_idx` (`book_id`),
  CONSTRAINT `fk_copy_book`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`book_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tracks individual physical copies of books';

-- -----------------------------------------------------
-- Table `loans`
-- Tracks book borrowing transactions
-- -----------------------------------------------------
CREATE TABLE `loans` (
  `loan_id` INT NOT NULL AUTO_INCREMENT,
  `copy_id` INT NOT NULL,
  `member_id` INT NOT NULL,
  `checkout_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `due_date` DATE NOT NULL,
  `return_date` DATETIME NULL,
  `checked_out_by` INT NOT NULL,
  `checked_in_by` INT NULL,
  `renewal_count` INT NOT NULL DEFAULT 0,
  `status` ENUM('Active', 'Returned', 'Overdue', 'Lost') NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`loan_id`),
  INDEX `idx_loan_status` (`status`),
  INDEX `fk_loan_copy_idx` (`copy_id`),
  INDEX `fk_loan_member_idx` (`member_id`),
  INDEX `fk_loan_checkout_staff_idx` (`checked_out_by`),
  INDEX `fk_loan_checkin_staff_idx` (`checked_in_by`),
  CONSTRAINT `fk_loan_copy`
    FOREIGN KEY (`copy_id`)
    REFERENCES `book_copies` (`copy_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_loan_member`
    FOREIGN KEY (`member_id`)
    REFERENCES `members` (`member_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_loan_checkout_staff`
    FOREIGN KEY (`checked_out_by`)
    REFERENCES `staff` (`staff_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_loan_checkin_staff`
    FOREIGN KEY (`checked_in_by`)
    REFERENCES `staff` (`staff_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tracks book borrowing records';

-- -----------------------------------------------------
-- Table `reservations`
-- Tracks book reservations
-- -----------------------------------------------------
CREATE TABLE `reservations` (
  `reservation_id` INT NOT NULL AUTO_INCREMENT,
  `book_id` INT NOT NULL,
  `member_id` INT NOT NULL,
  `reservation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expiry_date` DATE NOT NULL,
  `status` ENUM('Active', 'Fulfilled', 'Cancelled', 'Expired') NOT NULL DEFAULT 'Active',
  `staff_id` INT NULL,
  PRIMARY KEY (`reservation_id`),
  INDEX `idx_reservation_status` (`status`),
  INDEX `fk_reservation_book_idx` (`book_id`),
  INDEX `fk_reservation_member_idx` (`member_id`),
  INDEX `fk_reservation_staff_idx` (`staff_id`),
  CONSTRAINT `fk_reservation_book`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`book_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_reservation_member`
    FOREIGN KEY (`member_id`)
    REFERENCES `members` (`member_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_reservation_staff`
    FOREIGN KEY (`staff_id`)
    REFERENCES `staff` (`staff_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tracks book reservations';

-- -----------------------------------------------------
-- Table `fines`
-- Tracks member fines for late returns, damages, etc.
-- -----------------------------------------------------
CREATE TABLE `fines` (
  `fine_id` INT NOT NULL AUTO_INCREMENT,
  `loan_id` INT NULL,
  `member_id` INT NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `issued_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reason` VARCHAR(255) NOT NULL,
  `status` ENUM('Pending', 'Paid', 'Waived') NOT NULL DEFAULT 'Pending',
  `payment_date` DATETIME NULL,
  `collected_by` INT NULL,
  PRIMARY KEY (`fine_id`),
  INDEX `idx_fine_status` (`status`),
  INDEX `fk_fine_loan_idx` (`loan_id`),
  INDEX `fk_fine_member_idx` (`member_id`),
  INDEX `fk_fine_staff_idx` (`collected_by`),
  CONSTRAINT `fk_fine_loan`
    FOREIGN KEY (`loan_id`)
    REFERENCES `loans` (`loan_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_fine_member`
    FOREIGN KEY (`member_id`)
    REFERENCES `members` (`member_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_fine_staff`
    FOREIGN KEY (`collected_by`)
    REFERENCES `staff` (`staff_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tracks member fines';

-- -----------------------------------------------------
-- Table `reviews`
-- Stores book reviews by members
-- -----------------------------------------------------
CREATE TABLE `reviews` (
  `review_id` INT NOT NULL AUTO_INCREMENT,
  `book_id` INT NOT NULL,
  `member_id` INT NOT NULL,
  `rating` TINYINT NOT NULL,
  `review_text` TEXT NULL,
  `review_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_approved` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`review_id`),
  INDEX `fk_review_book_idx` (`book_id`),
  INDEX `fk_review_member_idx` (`member_id`),
  CONSTRAINT `fk_review_book`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`book_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_review_member`
    FOREIGN KEY (`member_id`)
    REFERENCES `members` (`member_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_rating_range` 
    CHECK (`rating` BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores book reviews by members';

-- -----------------------------------------------------
-- Table `events`
-- Library events like book clubs, readings, etc.
-- -----------------------------------------------------
CREATE TABLE `events` (
  `event_id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `start_time` DATETIME NOT NULL,
  `end_time` DATETIME NOT NULL,
  `location` VARCHAR(255) NOT NULL,
  `max_attendees` INT NULL,
  `organizer_id` INT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`event_id`),
  INDEX `idx_event_date` (`start_time`),
  INDEX `fk_event_organizer_idx` (`organizer_id`),
  CONSTRAINT `fk_event_organizer`
    FOREIGN KEY (`organizer_id`)
    REFERENCES `staff` (`staff_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `chk_event_times` 
    CHECK (`end_time` > `start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Library events information';

-- -----------------------------------------------------
-- Table `event_registrations`
-- Many-to-Many relationship between events and members
-- -----------------------------------------------------
CREATE TABLE `event_registrations` (
  `event_id` INT NOT NULL,
  `member_id` INT NOT NULL,
  `registration_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `attendance_status` ENUM('Registered', 'Attended', 'No-show', 'Cancelled') NOT NULL DEFAULT 'Registered',
  PRIMARY KEY (`event_id`, `member_id`),
  INDEX `fk_registration_member_idx` (`member_id`),
  CONSTRAINT `fk_registration_event`
    FOREIGN KEY (`event_id`)
    REFERENCES `events` (`event_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_registration_member`
    FOREIGN KEY (`member_id`)
    REFERENCES `members` (`member_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tracks member registrations for library events';

-- -----------------------------------------------------
-- Views
-- -----------------------------------------------------

-- View for overdue books
CREATE VIEW `vw_overdue_loans` AS
SELECT 
  l.loan_id,
  b.title,
  bc.barcode,
  CONCAT(m.first_name, ' ', m.last_name) AS member_name,
  m.email AS member_email,
  l.checkout_date,
  l.due_date,
  DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue
FROM `loans` l
JOIN `book_copies` bc ON l.copy_id = bc.copy_id
JOIN `books` b ON bc.book_id = b.book_id
JOIN `members` m ON l.member_id = m.member_id
WHERE l.status = 'Active' 
  AND l.due_date < CURRENT_DATE
  AND l.return_date IS NULL;

-- View for popular books (most borrowed)
CREATE VIEW `vw_popular_books` AS
SELECT 
  b.book_id,
  b.title,
  b.isbn,
  COUNT(l.loan_id) AS loan_count
FROM `books` b
JOIN `book_copies` bc ON b.book_id = bc.book_id
JOIN `loans` l ON bc.copy_id = l.copy_id
WHERE l.checkout_date >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH)
GROUP BY b.book_id, b.title, b.isbn
ORDER BY loan_count DESC;

-- View for book availability
CREATE VIEW `vw_book_availability` AS
SELECT 
  b.book_id,
  b.title,
  b.isbn,
  COUNT(bc.copy_id) AS total_copies,
  SUM(CASE WHEN bc.status = 'Available' THEN 1 ELSE 0 END) AS available_copies,
  SUM(CASE WHEN bc.status = 'On Loan' THEN 1 ELSE 0 END) AS copies_on_loan,
  SUM(CASE WHEN bc.status IN ('Lost', 'Damaged') THEN 1 ELSE 0 END) AS unavailable_copies
FROM `books` b
LEFT JOIN `book_copies` bc ON b.book_id = bc.book_id
GROUP BY b.book_id, b.title, b.isbn;

-- View for member borrowing activity
CREATE VIEW `vw_member_activity` AS
SELECT 
  m.member_id,
  CONCAT(m.first_name, ' ', m.last_name) AS member_name,
  m.email,
  COUNT(l.loan_id) AS total_loans,
  SUM(CASE WHEN l.status = 'Active' THEN 1 ELSE 0 END) AS active_loans,
  SUM(CASE WHEN l.status = 'Overdue' THEN 1 ELSE 0 END) AS overdue_loans,
  COUNT(DISTINCT f.fine_id) AS total_fines,
  SUM(CASE WHEN f.status = 'Pending' THEN f.amount ELSE 0 END) AS outstanding_fines
FROM `members` m
LEFT JOIN `loans` l ON m.member_id = l.member_id
LEFT JOIN `fines` f ON m.member_id = f.member_id
GROUP BY m.member_id, member_name, m.email;

-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------

-- Trigger to update book copy status when a loan is created
DELIMITER //
CREATE TRIGGER `trg_loan_created` 
AFTER INSERT ON `loans`
FOR EACH ROW
BEGIN
  UPDATE `book_copies` SET `status` = 'On Loan'
  WHERE `copy_id` = NEW.copy_id;
END //
DELIMITER ;

-- Trigger to update book copy status when a loan is returned
DELIMITER //
CREATE TRIGGER `trg_loan_returned` 
AFTER UPDATE ON `loans`
FOR EACH ROW
BEGIN
  IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
    UPDATE `book_copies` SET `status` = 'Available'
    WHERE `copy_id` = NEW.copy_id;
  END IF;
END //
DELIMITER ;

-- Trigger to automatically update loan status to 'Overdue' when due date passes
DELIMITER //
CREATE TRIGGER `trg_loan_overdue_check` 
BEFORE UPDATE ON `loans`
FOR EACH ROW
BEGIN
  IF NEW.due_date < CURRENT_DATE AND NEW.return_date IS NULL AND NEW.status = 'Active' THEN
    SET NEW.status = 'Overdue';
  END IF;
END //
DELIMITER ;

-- Trigger to check membership validity when creating a loan
DELIMITER //
CREATE TRIGGER `trg_check_membership` 
BEFORE INSERT ON `loans`
FOR EACH ROW
BEGIN
  DECLARE membership_valid BOOLEAN;
  
  SELECT (membership_expiry >= CURRENT_DATE AND membership_status = 'Active') 
  INTO membership_valid
  FROM `members`
  WHERE member_id = NEW.member_id;
  
  IF NOT membership_valid THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Member has expired or inactive membership';
  END IF;
END //
DELIMITER ;

-- -----------------------------------------------------
-- Stored Procedures
-- -----------------------------------------------------

-- Procedure to renew a loan
DELIMITER //
CREATE PROCEDURE `sp_renew_loan`(
  IN p_loan_id INT,
  IN p_staff_id INT,
  OUT p_success BOOLEAN,
  OUT p_message VARCHAR(255)
)
sp_main: BEGIN
  DECLARE v_member_id INT;
  DECLARE v_copy_id INT;
  DECLARE v_current_due_date DATE;
  DECLARE v_renewal_count INT;
  DECLARE v_has_reservation BOOLEAN DEFAULT FALSE;
  DECLARE v_has_overdue BOOLEAN DEFAULT FALSE;
  DECLARE v_has_fine BOOLEAN DEFAULT FALSE;
  
  -- Initialize output variables
  SET p_success = FALSE;
  SET p_message = '';
  
  -- Check if loan exists and get its details
  SELECT member_id, copy_id, due_date, renewal_count 
  INTO v_member_id, v_copy_id, v_current_due_date, v_renewal_count
  FROM `loans`
  WHERE loan_id = p_loan_id AND status = 'Active';
  
  IF v_member_id IS NULL THEN
    SET p_message = 'Loan not found or not active';
    LEAVE sp_main;
  END IF;
  
  -- Check if book has pending reservations
  SELECT TRUE INTO v_has_reservation
  FROM `book_copies` bc
  JOIN `books` b ON bc.book_id = b.book_id
  JOIN `reservations` r ON b.book_id = r.book_id
  WHERE bc.copy_id = v_copy_id
  AND r.status = 'Active'
  LIMIT 1;
  
  IF v_has_reservation THEN
    SET p_message = 'Book has pending reservations and cannot be renewed';
    LEAVE sp_main;
  END IF;
  
  -- Check if member has overdue books
  SELECT TRUE INTO v_has_overdue
  FROM `loans`
  WHERE member_id = v_member_id
  AND status = 'Overdue'
  LIMIT 1;
  
  IF v_has_overdue THEN
    SET p_message = 'Member has overdue books and cannot renew';
    LEAVE sp_main;
  END IF;
  
  -- Check if member has unpaid fines
  SELECT TRUE INTO v_has_fine
  FROM `fines`
  WHERE member_id = v_member_id
  AND status = 'Pending'
  LIMIT 1;
  
  IF v_has_fine THEN
    SET p_message = 'Member has unpaid fines and cannot renew';
    LEAVE sp_main;
  END IF;
  
  -- Check renewal limit (max 3 renewals)
  IF v_renewal_count >= 3 THEN
    SET p_message = 'Maximum renewal limit reached';
    LEAVE sp_main;
  END IF;
  
  -- All checks passed, renew the loan
  UPDATE `loans`
  SET due_date = DATE_ADD(GREATEST(v_current_due_date, CURRENT_DATE), INTERVAL 14 DAY),
      renewal_count = v_renewal_count + 1
  WHERE loan_id = p_loan_id;
  
  SET p_success = TRUE;
  SET p_message = 'Loan renewed successfully';
  
END //
DELIMITER ;

-- Procedure to calculate and create fine for overdue book
DELIMITER //
CREATE PROCEDURE `sp_create_overdue_fine`(
  IN p_loan_id INT
)
BEGIN
  DECLARE v_member_id INT;
  DECLARE v_days_overdue INT;
  DECLARE v_fine_amount DECIMAL(10,2);
  DECLARE v_due_date DATE;
  DECLARE v_return_date DATE;
  
  -- Get loan information
  SELECT member_id, due_date, return_date
  INTO v_member_id, v_due_date, v_return_date
  FROM `loans`
  WHERE loan_id = p_loan_id;
  
  -- Calculate days overdue
  IF v_return_date IS NOT NULL THEN
    SET v_days_overdue = DATEDIFF(v_return_date, v_due_date);
  ELSE
    SET v_days_overdue = DATEDIFF(CURRENT_DATE, v_due_date);
  END IF;
  
  -- Only create fine if actually overdue
  IF v_days_overdue > 0 THEN
    -- Calculate fine amount ($0.25 per day overdue)
    SET v_fine_amount = v_days_overdue * 0.25;
    
    -- Insert fine record
    INSERT INTO `fines` (
      loan_id, 
      member_id, 
      amount, 
      reason, 
      status
    )
    VALUES (
      p_loan_id, 
      v_member_id, 
      v_fine_amount, 
      CONCAT('Overdue book fine - ', v_days_overdue, ' days late'),
      'Pending'
    );
  END IF;
END //
DELIMITER ;

-- Procedure to check for and process books due today
DELIMITER //
CREATE PROCEDURE `sp_process_due_books`()
BEGIN
  -- Update any loans that are now overdue
  UPDATE `loans`
  SET status = 'Overdue'
  WHERE due_date < CURRENT_DATE
  AND return_date IS NULL
  AND status = 'Active';
  
  -- Create notifications for books due today (would connect to notification system)
  SELECT 
    l.loan_id,
    m.email AS member_email,
    b.title AS book_title,
    l.due_date
  FROM `loans` l
  JOIN `members` m ON l.member_id = m.member_id
  JOIN `book_copies` bc ON l.copy_id = bc.copy_id
  JOIN `books` b ON bc.book_id = b.book_id
  WHERE l.due_date = CURRENT_DATE
  AND l.return_date IS NULL
  AND l.status = 'Active';
END //
DELIMITER ;

-- Procedure to add new book with multiple authors
DELIMITER //
CREATE PROCEDURE `sp_add_new_book`(
  IN p_title VARCHAR(255),
  IN p_isbn VARCHAR(20),
  IN p_publication_date DATE,
  IN p_publisher_id INT,
  IN p_category_id INT,
  IN p_language VARCHAR(50),
  IN p_pages INT,
  IN p_description TEXT,
  IN p_author_ids VARCHAR(255),  -- Comma separated list of author IDs
  IN p_copy_count INT,           -- Number of copies to add
  OUT p_book_id INT              -- Returns the created book ID
)
BEGIN
  DECLARE v_book_id INT;
  DECLARE v_copy_counter INT DEFAULT 1;
  DECLARE v_author_id INT;
  DECLARE v_author_pos INT;
  DECLARE v_author_list VARCHAR(255);
  
  -- Insert main book record
  INSERT INTO `books` (
    title,
    isbn,
    publication_date,
    publisher_id,
    category_id,
    language,
    pages,
    description
  ) VALUES (
    p_title,
    p_isbn,
    p_publication_date,
    p_publisher_id,
    p_category_id,
    p_language,
    p_pages,
    p_description
  );
  
  SET v_book_id = LAST_INSERT_ID();
  SET p_book_id = v_book_id;
  
  -- Process authors (comma-separated list)
  SET v_author_list = p_author_ids;
  
  author_loop: WHILE LENGTH(v_author_list) > 0 DO
    -- Find position of the next comma
    SET v_author_pos = LOCATE(',', v_author_list);
    
    -- Extract author ID
    IF v_author_pos > 0 THEN
      SET v_author_id = CAST(SUBSTRING(v_author_list, 1, v_author_pos - 1) AS UNSIGNED);
      SET v_author_list = SUBSTRING(v_author_list, v_author_pos + 1);
    ELSE
      SET v_author_id = CAST(v_author_list AS UNSIGNED);
      SET v_author_list = '';
    END IF;
    
    -- Insert author link
    IF v_author_id > 0 THEN
      INSERT INTO `book_authors` (book_id, author_id)
      VALUES (v_book_id, v_author_id);
    END IF;
  END WHILE;
  
  -- Add copies of the book
  WHILE v_copy_counter <= p_copy_count DO
    INSERT INTO `book_copies` (
      book_id,
      barcode,
      acquisition_date,
      status
    ) VALUES (
      v_book_id,
      CONCAT(p_isbn, '-', LPAD(v_copy_counter, 3, '0')),
      CURRENT_DATE,
      'Available'
    );
    
    SET v_copy_counter = v_copy_counter + 1;
  END WHILE;
END //
DELIMITER ;

