-- BMGT 407 Hockey System SQL Dump
DROP DATABASE IF EXISTS user_management;
CREATE DATABASE user_management;
USE user_management;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS financial_projections;
DROP TABLE IF EXISTS financial_entries;
DROP TABLE IF EXISTS financial_categories;
DROP TABLE IF EXISTS practices;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================
-- USERS
-- =========================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL
);

-- =========================
-- PLAYERS
-- =========================
CREATE TABLE players (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    jersey_number INT,
    position VARCHAR(50),
    year VARCHAR(50),
    injured BOOLEAN DEFAULT FALSE,
    phone VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =========================
-- GAMES
-- Added schedule/results fields
-- =========================
CREATE TABLE games (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    opponent VARCHAR(100) NOT NULL,
    game_date DATE NOT NULL,
    location VARCHAR(150) NOT NULL,
    game_type ENUM('Home', 'Away') NOT NULL,
    status ENUM('Scheduled', 'Confirmed', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    projected_cost DECIMAL(10,2) DEFAULT NULL,
    actual_cost DECIMAL(10,2) DEFAULT NULL,
    final_score VARCHAR(50) DEFAULT NULL,
    notes VARCHAR(255) DEFAULT NULL,
    in_results BOOLEAN DEFAULT FALSE
);

-- =========================
-- PRACTICES
-- Added schedule/results fields
-- =========================
CREATE TABLE practices (
    practice_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    practice_date DATE NOT NULL,
    practice_time TIME NOT NULL,
    location VARCHAR(150) NOT NULL,
    contact_email VARCHAR(100),
    notes VARCHAR(255),
    status ENUM('Scheduled', 'Confirmed', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    projected_cost DECIMAL(10,2) DEFAULT NULL,
    actual_cost DECIMAL(10,2) DEFAULT NULL,
    in_results BOOLEAN DEFAULT FALSE
);

-- =========================
-- FINANCIAL CATEGORIES
-- =========================
CREATE TABLE financial_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_type ENUM('Revenue', 'Expense') NOT NULL
);

-- =========================
-- FINANCIAL ENTRIES
-- Now supports games AND practices
-- game_id and practice_id may both be NULL for general team-wide entries
-- =========================
CREATE TABLE financial_entries (
    entry_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NULL,
    practice_id INT NULL,
    category_id INT NOT NULL,
    entry_type ENUM('Revenue', 'Expense') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    description VARCHAR(255),
    entry_date DATE NOT NULL,
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE SET NULL,
    FOREIGN KEY (practice_id) REFERENCES practices(practice_id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES financial_categories(category_id)
);

-- =========================
-- FINANCIAL PROJECTIONS
-- Now supports games AND practices
-- =========================
CREATE TABLE financial_projections (
    projection_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NULL,
    practice_id INT NULL,
    category_id INT NOT NULL,
    projection_type ENUM('Revenue', 'Expense') NOT NULL,
    projected_amount DECIMAL(10,2) NOT NULL,
    notes VARCHAR(255),
    projection_date DATE NOT NULL,
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE SET NULL,
    FOREIGN KEY (practice_id) REFERENCES practices(practice_id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES financial_categories(category_id)
);

-- Helpful indexes
CREATE INDEX idx_games_date ON games(game_date);
CREATE INDEX idx_practices_date_time ON practices(practice_date, practice_time);
CREATE INDEX idx_financial_entries_game ON financial_entries(game_id);
CREATE INDEX idx_financial_entries_practice ON financial_entries(practice_id);
CREATE INDEX idx_financial_projections_game ON financial_projections(game_id);
CREATE INDEX idx_financial_projections_practice ON financial_projections(practice_id);

-- =========================
-- USERS SEED DATA
-- =========================
INSERT INTO users (id, name, email, password, role) VALUES
(1, 'Admin User', 'admin@umd.edu', 'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Admin'),
(2, 'Coach User', 'coach@umd.edu', 'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Coach'),
(3, 'Player User', 'player@umd.edu', 'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(4, 'Supplier User', 'supplier@umd.edu', 'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Supplier'),
(5, 'Marco Rossi', 'marco.rossi@umd.edu', 'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(6, 'Jake Thompson', 'jake.thompson@umd.edu', 'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(7, 'Liam Connor', 'liam.connor@umd.edu', 'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player');

ALTER TABLE users AUTO_INCREMENT = 8;

-- =========================
-- PLAYERS SEED DATA
-- =========================
INSERT INTO players (player_id, user_id, jersey_number, position, year, injured, phone) VALUES
(1, 3, 27, 'Forward', 'Sophomore', FALSE, '555-123-4567'),
(2, 5, 10, 'Defense', 'Senior', FALSE, '555-222-1111'),
(3, 6, 14, 'Forward', 'Junior', TRUE, '555-222-3333'),
(4, 7, 31, 'Goalie', 'Freshman', FALSE, '555-222-4444');

ALTER TABLE players AUTO_INCREMENT = 5;

-- =========================
-- FINANCIAL CATEGORIES SEED DATA
-- =========================
INSERT INTO financial_categories (category_id, category_name, category_type) VALUES
(1, 'Ticket Sales', 'Revenue'),
(2, 'Donation', 'Revenue'),
(3, 'Sponsorship', 'Revenue'),
(4, 'Merchandise Sales', 'Revenue'),
(5, 'Ref Fees', 'Expense'),
(6, 'Ice Rental', 'Expense'),
(7, 'Travel', 'Expense'),
(8, 'Equipment', 'Expense'),
(9, 'Facility', 'Expense'),
(10, 'Food and Hospitality', 'Expense');

ALTER TABLE financial_categories AUTO_INCREMENT = 11;

-- =========================
-- GAMES SEED DATA
-- =========================
INSERT INTO games (
    game_id, opponent, game_date, location, game_type, status,
    projected_cost, actual_cost, final_score, notes, in_results
) VALUES
(1, 'Georgetown Club Hockey', '2026-03-18', 'UMD Ice Arena', 'Home', 'Completed', 650.00, 620.00, 'UMD 4 - Georgetown 2', 'Strong home turnout and alumni support', TRUE),
(2, 'Navy Club Hockey', '2026-03-22', 'Navy Ice Rink', 'Away', 'Completed', 900.00, 950.00, 'UMD 3 - Navy 5', 'Bus and travel meal costs ran high', TRUE),
(3, 'Towson', '2026-03-28', 'UMD Ice Arena', 'Home', 'Completed', 700.00, 675.00, 'UMD 6 - Towson 1', 'Senior recognition night', TRUE),
(4, 'Johns Hopkins', '2026-04-07', 'Johns Hopkins Rink', 'Away', 'Confirmed', 850.00, NULL, NULL, 'Need final bus confirmation', FALSE),
(5, 'George Mason', '2026-04-12', 'UMD Ice Arena', 'Home', 'Scheduled', 600.00, NULL, NULL, 'Potential fundraising table in lobby', FALSE),
(6, 'Delaware Club Hockey', '2026-04-19', 'Delaware Ice Center', 'Away', 'Scheduled', 980.00, NULL, NULL, 'Overnight travel may be needed', FALSE),
(7, 'Maryland Alumni', '2026-04-26', 'UMD Ice Arena', 'Home', 'Scheduled', 500.00, NULL, NULL, 'Food and drinks planned after game', FALSE);

ALTER TABLE games AUTO_INCREMENT = 8;

-- =========================
-- PRACTICES SEED DATA
-- =========================
INSERT INTO practices (
    practice_id, title, practice_date, practice_time, location, contact_email, notes,
    status, projected_cost, actual_cost, in_results
) VALUES
(1, 'Terps Ice Hockey Practice', '2026-03-12', '19:00:00', 'Campus Ice Rink', 'ice@rink.com', 'Power play and defensive zone', 'Completed', 300.00, 295.00, TRUE),
(2, 'Terps Ice Hockey Practice', '2026-03-14', '19:00:00', 'Community Ice Arena', 'ice@rink.com', 'Scrimmage and line combinations', 'Completed', 275.00, 280.00, TRUE),
(3, 'Terps Ice Hockey Practice', '2026-03-16', '18:30:00', 'Campus Ice Rink', 'ice@rink.com', 'Game prep and penalty kill', 'Completed', 325.00, 315.00, TRUE),
(4, 'Terps Ice Hockey Practice', '2026-04-02', '19:00:00', 'Campus Ice Rink', 'ice@rink.com', 'Spring training kickoff', 'Confirmed', 300.00, NULL, FALSE),
(5, 'Terps Ice Hockey Practice', '2026-04-09', '19:00:00', 'Community Ice Arena', 'ice@rink.com', 'Open ice', 'Scheduled', 310.00, NULL, FALSE);

ALTER TABLE practices AUTO_INCREMENT = 6;

-- =========================
-- FINANCIAL ENTRIES SEED DATA
-- game_id and practice_id may both be NULL for general entries
-- =========================
INSERT INTO financial_entries (
    entry_id, game_id, practice_id, category_id, entry_type, amount, description, entry_date
) VALUES
(1, 1, NULL, 1, 'Revenue', 1800.00, '120 tickets sold at $15', '2026-03-18'),
(2, 1, NULL, 4, 'Revenue', 320.00, 'Game-day merchandise sales', '2026-03-18'),
(3, 1, NULL, 5, 'Expense', 300.00, 'Referee fees', '2026-03-18'),
(4, 1, NULL, 6, 'Expense', 400.00, 'Ice rental', '2026-03-18'),
(5, 1, NULL, 10, 'Expense', 150.00, 'Snacks and drinks for event staff', '2026-03-18'),

(6, 2, NULL, 7, 'Expense', 500.00, 'Bus transportation', '2026-03-22'),
(7, 2, NULL, 5, 'Expense', 280.00, 'Referee fees', '2026-03-22'),
(8, 2, NULL, 10, 'Expense', 120.00, 'Team food before game', '2026-03-22'),

(9, 3, NULL, 1, 'Revenue', 2100.00, '140 tickets sold at $15', '2026-03-28'),
(10, 3, NULL, 2, 'Revenue', 500.00, 'Alumni donation received during event', '2026-03-28'),
(11, 3, NULL, 4, 'Revenue', 280.00, 'Merchandise sales', '2026-03-28'),
(12, 3, NULL, 5, 'Expense', 300.00, 'Referee fees', '2026-03-28'),
(13, 3, NULL, 6, 'Expense', 420.00, 'Ice rental', '2026-03-28'),
(14, 3, NULL, 9, 'Expense', 100.00, 'Arena support costs', '2026-03-28'),

(15, NULL, 1, 6, 'Expense', 240.00, 'Practice ice rental - Mar 12', '2026-03-12'),
(16, NULL, 1, 10, 'Expense', 55.00, 'Water and snacks - Mar 12 practice', '2026-03-12'),
(17, NULL, 2, 6, 'Expense', 250.00, 'Practice ice rental - Mar 14', '2026-03-14'),
(18, NULL, 2, 10, 'Expense', 30.00, 'Post-practice snacks - Mar 14 practice', '2026-03-14'),
(19, NULL, 3, 6, 'Expense', 260.00, 'Practice ice rental - Mar 16', '2026-03-16'),
(20, NULL, 3, 8, 'Expense', 55.00, 'Pucks and tape for practice', '2026-03-16'),

(21, NULL, NULL, 2, 'Revenue', 1500.00, 'General alumni donation', '2026-04-01'),
(22, NULL, NULL, 8, 'Expense', 725.00, 'General equipment order', '2026-04-03');

ALTER TABLE financial_entries AUTO_INCREMENT = 23;

-- =========================
-- FINANCIAL PROJECTIONS SEED DATA
-- =========================
INSERT INTO financial_projections (
    projection_id, game_id, practice_id, category_id, projection_type, projected_amount, notes, projection_date
) VALUES
(1, 1, NULL, 1, 'Revenue', 1700.00, 'Projected ticket sales', '2026-03-18'),
(2, 1, NULL, 4, 'Revenue', 300.00, 'Projected merchandise sales', '2026-03-18'),
(3, 1, NULL, 5, 'Expense', 300.00, 'Projected ref fees', '2026-03-18'),
(4, 1, NULL, 6, 'Expense', 425.00, 'Projected ice rental', '2026-03-18'),

(5, 2, NULL, 7, 'Expense', 520.00, 'Projected travel cost', '2026-03-22'),
(6, 2, NULL, 5, 'Expense', 275.00, 'Projected ref fees', '2026-03-22'),
(7, 2, NULL, 10, 'Expense', 125.00, 'Projected food cost', '2026-03-22'),

(8, 3, NULL, 1, 'Revenue', 2000.00, 'Projected ticket sales', '2026-03-28'),
(9, 3, NULL, 2, 'Revenue', 400.00, 'Projected donations', '2026-03-28'),
(10, 3, NULL, 4, 'Revenue', 250.00, 'Projected merchandise sales', '2026-03-28'),
(11, 3, NULL, 5, 'Expense', 300.00, 'Projected ref fees', '2026-03-28'),
(12, 3, NULL, 6, 'Expense', 450.00, 'Projected ice rental', '2026-03-28'),

(13, NULL, 1, 6, 'Expense', 250.00, 'Projected practice ice rental - Mar 12', '2026-03-12'),
(14, NULL, 1, 10, 'Expense', 50.00, 'Projected snacks - Mar 12 practice', '2026-03-12'),
(15, NULL, 2, 6, 'Expense', 250.00, 'Projected practice ice rental - Mar 14', '2026-03-14'),
(16, NULL, 2, 10, 'Expense', 25.00, 'Projected snacks - Mar 14 practice', '2026-03-14'),
(17, NULL, 3, 6, 'Expense', 260.00, 'Projected practice ice rental - Mar 16', '2026-03-16'),
(18, NULL, 3, 8, 'Expense', 60.00, 'Projected supplies - Mar 16 practice', '2026-03-16');

ALTER TABLE financial_projections AUTO_INCREMENT = 19;
