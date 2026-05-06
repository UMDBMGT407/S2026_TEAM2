-- BMGT 407 Hockey System SQL Dump
DROP DATABASE IF EXISTS user_management;
CREATE DATABASE user_management;
USE user_management;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS donations;
DROP TABLE IF EXISTS alumni;
DROP TABLE IF EXISTS newsletters;
DROP TABLE IF EXISTS equipment_orders;
DROP TABLE IF EXISTS inventory_items;
DROP TABLE IF EXISTS financial_projections;
DROP TABLE IF EXISTS financial_entries;
DROP TABLE IF EXISTS financial_categories;
DROP TABLE IF EXISTS practices;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS subscribers;
DROP TABLE IF EXISTS sent_messages;
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
-- SENT MESSAGES
-- =========================
CREATE TABLE IF NOT EXISTS sent_messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    recipients VARCHAR(100) NOT NULL,
    subject VARCHAR(200),
    body TEXT,
    sent_by INT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sent_by) REFERENCES users(id)
);

-- =========================
-- FINANCIAL ENTRIES
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
-- password for all = test123
-- =========================
INSERT INTO users (id, name, email, password, role) VALUES
(1,  'Admin User',       'admin@umd.edu',            'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Admin'),
(2,  'Coach User',       'coach@umd.edu',            'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Coach'),
(3,  'Player User',      'player@umd.edu',           'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(4,  'Supplier User',    'supplier@umd.edu',         'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Supplier'),
(5,  'Marco Rossi',      'marco.rossi@umd.edu',      'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(6,  'Jake Thompson',    'jake.thompson@umd.edu',    'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(7,  'Liam Connor',      'liam.connor@umd.edu',      'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(8,  'Tyler Brooks',     'tyler.brooks@umd.edu',     'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(9,  'Evan Walsh',       'evan.walsh@umd.edu',       'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(10, 'Chris Navarro',    'chris.navarro@umd.edu',    'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(11, 'Derek Huang',      'derek.huang@umd.edu',      'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(12, 'Mason Price',      'mason.price@umd.edu',      'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(13, 'Owen Fitzgerald',  'owen.fitz@umd.edu',        'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(14, 'Nate Summers',     'nate.summers@umd.edu',     'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(15, 'Brady Okafor',     'brady.okafor@umd.edu',     'scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Player'),
(16, 'Sports Supply Co', 'supplier2@sportssupply.com','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d', 'Supplier');

ALTER TABLE users AUTO_INCREMENT = 17;

-- =========================
-- PLAYERS SEED DATA
-- =========================
INSERT INTO players (player_id, user_id, jersey_number, position, year, injured, phone) VALUES
(1,  3,  27, 'Forward',  'Sophomore', FALSE, '555-123-4567'),
(2,  5,  10, 'Defense',  'Senior',    FALSE, '555-222-1111'),
(3,  6,  14, 'Forward',  'Junior',    TRUE,  '555-222-3333'),
(4,  7,  31, 'Goalie',   'Freshman',  FALSE, '555-222-4444'),
(5,  8,   7, 'Forward',  'Junior',    FALSE, '555-333-1001'),
(6,  9,  22, 'Defense',  'Sophomore', FALSE, '555-333-1002'),
(7,  10, 18, 'Forward',  'Senior',    TRUE,  '555-333-1003'),
(8,  11,  3, 'Defense',  'Freshman',  FALSE, '555-333-1004'),
(9,  12, 11, 'Forward',  'Junior',    FALSE, '555-333-1005'),
(10, 13, 44, 'Defense',  'Senior',    FALSE, '555-333-1006'),
(11, 14, 19, 'Goalie',   'Sophomore', FALSE, '555-333-1007'),
(12, 15,  8, 'Forward',  'Junior',    FALSE, '555-333-1008');

ALTER TABLE players AUTO_INCREMENT = 13;

-- =========================
-- FINANCIAL CATEGORIES SEED DATA
-- =========================
INSERT INTO financial_categories (category_id, category_name, category_type) VALUES
(1,  'Ticket Sales',       'Revenue'),
(2,  'Donation',           'Revenue'),
(3,  'Sponsorship',        'Revenue'),
(4,  'Merchandise Sales',  'Revenue'),
(5,  'Ref Fees',           'Expense'),
(6,  'Ice Rental',         'Expense'),
(7,  'Travel',             'Expense'),
(8,  'Equipment',          'Expense'),
(9,  'Facility',           'Expense'),
(10, 'Food and Hospitality','Expense');

ALTER TABLE financial_categories AUTO_INCREMENT = 11;

-- =========================
-- GAMES SEED DATA
-- Past games (in_results = TRUE), upcoming (in_results = FALSE)
-- =========================
INSERT INTO games (
    game_id, opponent, game_date, location, game_type, status,
    projected_cost, actual_cost, final_score, notes, in_results
) VALUES
-- Past / completed games
(1,  'Georgetown Club Hockey', '2026-01-10', 'UMD Ice Arena',         'Home', 'Completed', 620.00,  598.00,  'UMD 5 - Georgetown 1', 'Strong start to the spring semester', TRUE),
(2,  'American University',    '2026-01-17', 'AU Ice Center',         'Away', 'Completed', 850.00,  890.00,  'UMD 2 - AU 3',         'Overtime loss, close game', TRUE),
(3,  'Virginia Tech Club',     '2026-01-24', 'UMD Ice Arena',         'Home', 'Completed', 600.00,  575.00,  'UMD 4 - VT 2',         'Good crowd for a January game', TRUE),
(4,  'Penn State Club',        '2026-02-07', 'Penn State Ice Rink',   'Away', 'Completed', 1100.00, 1145.00, 'UMD 1 - PSU 4',        'Long bus trip, tough loss', TRUE),
(5,  'George Washington',      '2026-02-14', 'UMD Ice Arena',         'Home', 'Completed', 650.00,  630.00,  'UMD 6 - GWU 0',        'Valentine\'s Day shutout win', TRUE),
(6,  'Catholic University',    '2026-02-21', 'Catholic Ice Rink',     'Away', 'Completed', 780.00,  760.00,  'UMD 3 - CU 3',         'Tie game, split point', TRUE),
(7,  'Georgetown Club Hockey', '2026-03-07', 'UMD Ice Arena',         'Home', 'Completed', 640.00,  615.00,  'UMD 4 - Georgetown 1', 'Rematch win at home', TRUE),
(8,  'Navy Club Hockey',       '2026-03-14', 'UMD Ice Arena',         'Home', 'Completed', 670.00,  650.00,  'UMD 5 - Navy 2',       'Home win before road trip', TRUE),
(9,  'Georgetown Club Hockey', '2026-03-18', 'UMD Ice Arena',         'Home', 'Completed', 650.00,  620.00,  'UMD 4 - Georgetown 2', 'Strong home turnout and alumni support', TRUE),
(10, 'Navy Club Hockey',       '2026-03-22', 'Navy Ice Rink',         'Away', 'Completed', 900.00,  950.00,  'UMD 3 - Navy 5',       'Bus and travel meal costs ran high', TRUE),
(11, 'Towson',                 '2026-03-28', 'UMD Ice Arena',         'Home', 'Completed', 700.00,  675.00,  'UMD 6 - Towson 1',     'Senior recognition night', TRUE),
-- Upcoming games
(12, 'Johns Hopkins',          '2026-04-07', 'Johns Hopkins Rink',    'Away', 'Confirmed', 850.00,  NULL,    NULL, 'Need final bus confirmation', FALSE),
(13, 'George Mason',           '2026-04-12', 'UMD Ice Arena',         'Home', 'Scheduled', 600.00,  NULL,    NULL, 'Potential fundraising table in lobby', FALSE),
(14, 'Delaware Club Hockey',   '2026-04-19', 'Delaware Ice Center',   'Away', 'Scheduled', 980.00,  NULL,    NULL, 'Overnight travel may be needed', FALSE),
(15, 'Maryland Alumni',        '2026-04-26', 'UMD Ice Arena',         'Home', 'Scheduled', 500.00,  NULL,    NULL, 'Food and drinks planned after game', FALSE),
(16, 'Virginia Tech Club',     '2026-05-02', 'Cassell Coliseum Ice',  'Away', 'Scheduled', 1050.00, NULL,    NULL, 'End of season road game', FALSE),
(17, 'American University',    '2026-05-09', 'UMD Ice Arena',         'Home', 'Scheduled', 620.00,  NULL,    NULL, 'Final home game of the season', FALSE);

ALTER TABLE games AUTO_INCREMENT = 18;

-- =========================
-- PRACTICES SEED DATA
-- =========================
INSERT INTO practices (
    practice_id, title, practice_date, practice_time, location, contact_email, notes,
    status, projected_cost, actual_cost, in_results
) VALUES
-- Past practices
(1,  'Terps Ice Hockey Practice', '2026-01-08', '19:00:00', 'Campus Ice Rink',     'ice@rink.com', 'Season opener skate - conditioning focus',    'Completed', 300.00, 295.00, TRUE),
(2,  'Terps Ice Hockey Practice', '2026-01-13', '19:00:00', 'Community Ice Arena', 'ice@rink.com', 'Power play and defensive zone work',          'Completed', 275.00, 280.00, TRUE),
(3,  'Terps Ice Hockey Practice', '2026-01-20', '18:30:00', 'Campus Ice Rink',     'ice@rink.com', 'Line combinations and neutral zone',          'Completed', 325.00, 315.00, TRUE),
(4,  'Terps Ice Hockey Practice', '2026-01-27', '19:00:00', 'Campus Ice Rink',     'ice@rink.com', 'Penalty kill and 5-on-3 defense',             'Completed', 300.00, 310.00, TRUE),
(5,  'Terps Ice Hockey Practice', '2026-02-03', '19:00:00', 'Community Ice Arena', 'ice@rink.com', 'Full scrimmage with video review',            'Completed', 310.00, 305.00, TRUE),
(6,  'Terps Ice Hockey Practice', '2026-02-10', '18:30:00', 'Campus Ice Rink',     'ice@rink.com', 'Pre-PSU game skate',                          'Completed', 290.00, 285.00, TRUE),
(7,  'Terps Ice Hockey Practice', '2026-02-17', '19:00:00', 'Campus Ice Rink',     'ice@rink.com', 'Breakout drills and transition play',         'Completed', 300.00, 298.00, TRUE),
(8,  'Terps Ice Hockey Practice', '2026-02-24', '19:00:00', 'Community Ice Arena', 'ice@rink.com', 'Special teams focus',                         'Completed', 275.00, 270.00, TRUE),
(9,  'Terps Ice Hockey Practice', '2026-03-03', '18:30:00', 'Campus Ice Rink',     'ice@rink.com', 'Mid-season assessment skate',                 'Completed', 310.00, 315.00, TRUE),
(10, 'Terps Ice Hockey Practice', '2026-03-10', '19:00:00', 'Campus Ice Rink',     'ice@rink.com', 'Pre-stretch run conditioning',                'Completed', 300.00, 295.00, TRUE),
(11, 'Terps Ice Hockey Practice', '2026-03-12', '19:00:00', 'Campus Ice Rink',     'ice@rink.com', 'Power play and defensive zone',               'Completed', 300.00, 295.00, TRUE),
(12, 'Terps Ice Hockey Practice', '2026-03-14', '19:00:00', 'Community Ice Arena', 'ice@rink.com', 'Scrimmage and line combinations',             'Completed', 275.00, 280.00, TRUE),
(13, 'Terps Ice Hockey Practice', '2026-03-16', '18:30:00', 'Campus Ice Rink',     'ice@rink.com', 'Game prep and penalty kill',                  'Completed', 325.00, 315.00, TRUE),
-- Upcoming practices
(14, 'Terps Ice Hockey Practice', '2026-04-02', '19:00:00', 'Campus Ice Rink',     'ice@rink.com', 'Spring training kickoff',                     'Confirmed', 300.00, NULL, FALSE),
(15, 'Terps Ice Hockey Practice', '2026-04-09', '19:00:00', 'Community Ice Arena', 'ice@rink.com', 'Open ice and line rushes',                    'Scheduled', 310.00, NULL, FALSE),
(16, 'Terps Ice Hockey Practice', '2026-04-14', '18:30:00', 'Campus Ice Rink',     'ice@rink.com', 'Pre-Delaware game skate',                     'Scheduled', 290.00, NULL, FALSE),
(17, 'Terps Ice Hockey Practice', '2026-04-21', '19:00:00', 'Campus Ice Rink',     'ice@rink.com', 'Post-Delaware recovery and film',             'Scheduled', 300.00, NULL, FALSE),
(18, 'Terps Ice Hockey Practice', '2026-04-28', '19:00:00', 'Community Ice Arena', 'ice@rink.com', 'End of season conditioning',                  'Scheduled', 310.00, NULL, FALSE),
(19, 'Terps Ice Hockey Practice', '2026-05-05', '18:30:00', 'Campus Ice Rink',     'ice@rink.com', 'Final prep before season close',              'Scheduled', 300.00, NULL, FALSE);

ALTER TABLE practices AUTO_INCREMENT = 20;

-- =========================
-- FINANCIAL ENTRIES SEED DATA
-- =========================
INSERT INTO financial_entries (
    entry_id, game_id, practice_id, category_id, entry_type, amount, description, entry_date
) VALUES
-- Game 1 (Georgetown Jan)
(1,  1, NULL, 1, 'Revenue',  1500.00, '100 tickets sold at $15',             '2026-01-10'),
(2,  1, NULL, 4, 'Revenue',   240.00, 'Merchandise sales',                   '2026-01-10'),
(3,  1, NULL, 5, 'Expense',   300.00, 'Referee fees',                        '2026-01-10'),
(4,  1, NULL, 6, 'Expense',   400.00, 'Ice rental',                          '2026-01-10'),

-- Game 2 (AU away)
(5,  2, NULL, 7, 'Expense',   520.00, 'Bus transportation to AU',            '2026-01-17'),
(6,  2, NULL, 5, 'Expense',   270.00, 'Referee fees',                        '2026-01-17'),
(7,  2, NULL, 10,'Expense',   100.00, 'Team meal on road',                   '2026-01-17'),

-- Game 3 (VT home)
(8,  3, NULL, 1, 'Revenue',  1650.00, '110 tickets sold at $15',             '2026-01-24'),
(9,  3, NULL, 3, 'Revenue',   500.00, 'Corporate sponsorship game night',    '2026-01-24'),
(10, 3, NULL, 5, 'Expense',   300.00, 'Referee fees',                        '2026-01-24'),
(11, 3, NULL, 6, 'Expense',   410.00, 'Ice rental',                          '2026-01-24'),

-- Game 4 (PSU away)
(12, 4, NULL, 7, 'Expense',   850.00, 'Charter bus to Penn State',           '2026-02-07'),
(13, 4, NULL, 5, 'Expense',   290.00, 'Referee fees',                        '2026-02-07'),
(14, 4, NULL, 10,'Expense',   150.00, 'Two team meals on road trip',         '2026-02-07'),
(15, 4, NULL, 9, 'Expense',    55.00, 'Facility access fee',                 '2026-02-07'),

-- Game 5 (GWU home - Valentine's Day)
(16, 5, NULL, 1, 'Revenue',  1950.00, '130 tickets sold at $15',             '2026-02-14'),
(17, 5, NULL, 4, 'Revenue',   310.00, 'Merchandise and concession share',    '2026-02-14'),
(18, 5, NULL, 2, 'Revenue',   400.00, 'Booster club donation at game',       '2026-02-14'),
(19, 5, NULL, 5, 'Expense',   300.00, 'Referee fees',                        '2026-02-14'),
(20, 5, NULL, 6, 'Expense',   415.00, 'Ice rental',                          '2026-02-14'),

-- Game 6 (Catholic away)
(21, 6, NULL, 7, 'Expense',   460.00, 'Van rental and gas',                  '2026-02-21'),
(22, 6, NULL, 5, 'Expense',   270.00, 'Referee fees',                        '2026-02-21'),

-- Game 7 (Georgetown March rematch)
(23, 7, NULL, 1, 'Revenue',  1800.00, '120 tickets sold at $15',             '2026-03-07'),
(24, 7, NULL, 4, 'Revenue',   290.00, 'Merchandise sales',                   '2026-03-07'),
(25, 7, NULL, 5, 'Expense',   300.00, 'Referee fees',                        '2026-03-07'),
(26, 7, NULL, 6, 'Expense',   400.00, 'Ice rental',                          '2026-03-07'),

-- Game 8 (Navy home March)
(27, 8, NULL, 1, 'Revenue',  1725.00, '115 tickets sold at $15',             '2026-03-14'),
(28, 8, NULL, 3, 'Revenue',   750.00, 'Mid-season sponsor payment',          '2026-03-14'),
(29, 8, NULL, 5, 'Expense',   300.00, 'Referee fees',                        '2026-03-14'),
(30, 8, NULL, 6, 'Expense',   400.00, 'Ice rental',                          '2026-03-14'),
(31, 8, NULL, 10,'Expense',    75.00, 'Halftime refreshments',               '2026-03-14'),

-- Game 9 (Georgetown Mar 18)
(32, 9, NULL, 1, 'Revenue',  1800.00, '120 tickets sold at $15',             '2026-03-18'),
(33, 9, NULL, 4, 'Revenue',   320.00, 'Game-day merchandise sales',          '2026-03-18'),
(34, 9, NULL, 5, 'Expense',   300.00, 'Referee fees',                        '2026-03-18'),
(35, 9, NULL, 6, 'Expense',   400.00, 'Ice rental',                          '2026-03-18'),
(36, 9, NULL, 10,'Expense',   150.00, 'Snacks and drinks for event staff',   '2026-03-18'),

-- Game 10 (Navy away Mar 22)
(37, 10,NULL, 7, 'Expense',   500.00, 'Bus transportation',                  '2026-03-22'),
(38, 10,NULL, 5, 'Expense',   280.00, 'Referee fees',                        '2026-03-22'),
(39, 10,NULL, 10,'Expense',   120.00, 'Team food before game',               '2026-03-22'),

-- Game 11 (Towson Mar 28)
(40, 11,NULL, 1, 'Revenue',  2100.00, '140 tickets sold at $15',             '2026-03-28'),
(41, 11,NULL, 2, 'Revenue',   500.00, 'Alumni donation received during event','2026-03-28'),
(42, 11,NULL, 4, 'Revenue',   280.00, 'Merchandise sales',                   '2026-03-28'),
(43, 11,NULL, 5, 'Expense',   300.00, 'Referee fees',                        '2026-03-28'),
(44, 11,NULL, 6, 'Expense',   420.00, 'Ice rental',                          '2026-03-28'),
(45, 11,NULL, 9, 'Expense',   100.00, 'Arena support costs',                 '2026-03-28'),

-- Past practice expenses (practices 1-13)
(46, NULL, 1,  6, 'Expense',  290.00, 'Practice ice rental - Jan 8',         '2026-01-08'),
(47, NULL, 1,  10,'Expense',   45.00, 'Water and snacks',                    '2026-01-08'),
(48, NULL, 2,  6, 'Expense',  265.00, 'Practice ice rental - Jan 13',        '2026-01-13'),
(49, NULL, 2,  10,'Expense',   40.00, 'Post-practice snacks',                '2026-01-13'),
(50, NULL, 3,  6, 'Expense',  280.00, 'Practice ice rental - Jan 20',        '2026-01-20'),
(51, NULL, 3,  8, 'Expense',   60.00, 'New pucks and tape',                  '2026-01-20'),
(52, NULL, 4,  6, 'Expense',  285.00, 'Practice ice rental - Jan 27',        '2026-01-27'),
(53, NULL, 4,  10,'Expense',   50.00, 'Snacks and drinks',                   '2026-01-27'),
(54, NULL, 5,  6, 'Expense',  270.00, 'Practice ice rental - Feb 3',         '2026-02-03'),
(55, NULL, 5,  10,'Expense',   55.00, 'Post-scrimmage food',                 '2026-02-03'),
(56, NULL, 6,  6, 'Expense',  260.00, 'Practice ice rental - Feb 10',        '2026-02-10'),
(57, NULL, 7,  6, 'Expense',  275.00, 'Practice ice rental - Feb 17',        '2026-02-17'),
(58, NULL, 7,  8, 'Expense',   45.00, 'Stick tape and misc supplies',        '2026-02-17'),
(59, NULL, 8,  6, 'Expense',  255.00, 'Practice ice rental - Feb 24',        '2026-02-24'),
(60, NULL, 9,  6, 'Expense',  285.00, 'Practice ice rental - Mar 3',         '2026-03-03'),
(61, NULL, 9,  10,'Expense',   50.00, 'Energy drinks for late practice',     '2026-03-03'),
(62, NULL, 10, 6, 'Expense',  275.00, 'Practice ice rental - Mar 10',        '2026-03-10'),
(63, NULL, 11, 6, 'Expense',  240.00, 'Practice ice rental - Mar 12',        '2026-03-12'),
(64, NULL, 11, 10,'Expense',   55.00, 'Water and snacks - Mar 12',           '2026-03-12'),
(65, NULL, 12, 6, 'Expense',  250.00, 'Practice ice rental - Mar 14',        '2026-03-14'),
(66, NULL, 12, 10,'Expense',   30.00, 'Post-practice snacks - Mar 14',       '2026-03-14'),
(67, NULL, 13, 6, 'Expense',  260.00, 'Practice ice rental - Mar 16',        '2026-03-16'),
(68, NULL, 13, 8, 'Expense',   55.00, 'Pucks and tape for practice',         '2026-03-16'),

-- General team-wide entries
(69, NULL, NULL, 2, 'Revenue', 1500.00, 'General alumni donation - spring drive',  '2026-04-01'),
(70, NULL, NULL, 3, 'Revenue', 2000.00, 'Annual jersey sponsorship - Terrapin Sports', '2026-01-05'),
(71, NULL, NULL, 3, 'Revenue', 1200.00, 'Booster club contribution Q1',       '2026-02-01'),
(72, NULL, NULL, 8, 'Expense',  725.00, 'General equipment order - sticks and pads', '2026-04-03'),
(73, NULL, NULL, 8, 'Expense',  450.00, 'Helmet replacement - 3 units',       '2026-02-15'),
(74, NULL, NULL, 9, 'Expense',  350.00, 'Locker room maintenance fee',         '2026-03-01'),
(75, NULL, NULL, 7, 'Expense',  200.00, 'Gas reimbursements for carpool games','2026-02-28');

ALTER TABLE financial_entries AUTO_INCREMENT = 76;

-- =========================
-- FINANCIAL PROJECTIONS SEED DATA
-- =========================
INSERT INTO financial_projections (
    projection_id, game_id, practice_id, category_id, projection_type, projected_amount, notes, projection_date
) VALUES
-- Game 1 projections
(1,  1, NULL, 1, 'Revenue', 1400.00, 'Projected ticket sales',              '2026-01-10'),
(2,  1, NULL, 5, 'Expense',  300.00, 'Projected ref fees',                  '2026-01-10'),
(3,  1, NULL, 6, 'Expense',  400.00, 'Projected ice rental',                '2026-01-10'),

-- Game 3 projections
(4,  3, NULL, 1, 'Revenue', 1500.00, 'Projected ticket sales',              '2026-01-24'),
(5,  3, NULL, 3, 'Revenue',  400.00, 'Projected sponsorship',               '2026-01-24'),
(6,  3, NULL, 5, 'Expense',  300.00, 'Projected ref fees',                  '2026-01-24'),
(7,  3, NULL, 6, 'Expense',  420.00, 'Projected ice rental',                '2026-01-24'),

-- Game 4 projections
(8,  4, NULL, 7, 'Expense',  800.00, 'Projected charter bus',               '2026-02-07'),
(9,  4, NULL, 5, 'Expense',  290.00, 'Projected ref fees',                  '2026-02-07'),
(10, 4, NULL, 10,'Expense',  120.00, 'Projected meals',                     '2026-02-07'),

-- Game 5 projections
(11, 5, NULL, 1, 'Revenue', 1800.00, 'Projected ticket sales',              '2026-02-14'),
(12, 5, NULL, 4, 'Revenue',  280.00, 'Projected merch sales',               '2026-02-14'),
(13, 5, NULL, 5, 'Expense',  300.00, 'Projected ref fees',                  '2026-02-14'),
(14, 5, NULL, 6, 'Expense',  420.00, 'Projected ice rental',                '2026-02-14'),

-- Game 9 projections (Georgetown Mar 18)
(15, 9, NULL, 1, 'Revenue', 1700.00, 'Projected ticket sales',              '2026-03-18'),
(16, 9, NULL, 4, 'Revenue',  300.00, 'Projected merchandise sales',         '2026-03-18'),
(17, 9, NULL, 5, 'Expense',  300.00, 'Projected ref fees',                  '2026-03-18'),
(18, 9, NULL, 6, 'Expense',  425.00, 'Projected ice rental',                '2026-03-18'),

-- Game 10 projections (Navy away)
(19, 10,NULL, 7, 'Expense',  520.00, 'Projected travel cost',               '2026-03-22'),
(20, 10,NULL, 5, 'Expense',  275.00, 'Projected ref fees',                  '2026-03-22'),
(21, 10,NULL, 10,'Expense',  125.00, 'Projected food cost',                 '2026-03-22'),

-- Game 11 projections (Towson)
(22, 11,NULL, 1, 'Revenue', 2000.00, 'Projected ticket sales',              '2026-03-28'),
(23, 11,NULL, 2, 'Revenue',  400.00, 'Projected donations',                 '2026-03-28'),
(24, 11,NULL, 4, 'Revenue',  250.00, 'Projected merchandise sales',         '2026-03-28'),
(25, 11,NULL, 5, 'Expense',  300.00, 'Projected ref fees',                  '2026-03-28'),
(26, 11,NULL, 6, 'Expense',  450.00, 'Projected ice rental',                '2026-03-28'),

-- Upcoming game projections
(27, 12,NULL, 7, 'Expense',  820.00, 'Projected bus to Hopkins',            '2026-04-07'),
(28, 12,NULL, 5, 'Expense',  290.00, 'Projected ref fees',                  '2026-04-07'),
(29, 12,NULL, 10,'Expense',  130.00, 'Projected team meal',                 '2026-04-07'),
(30, 13,NULL, 1, 'Revenue', 1800.00, 'Projected ticket sales',              '2026-04-12'),
(31, 13,NULL, 4, 'Revenue',  300.00, 'Projected merch',                     '2026-04-12'),
(32, 13,NULL, 5, 'Expense',  300.00, 'Projected ref fees',                  '2026-04-12'),
(33, 13,NULL, 6, 'Expense',  420.00, 'Projected ice rental',                '2026-04-12'),
(34, 14,NULL, 7, 'Expense',  950.00, 'Projected overnight travel',          '2026-04-19'),
(35, 14,NULL, 5, 'Expense',  290.00, 'Projected ref fees',                  '2026-04-19'),
(36, 14,NULL, 10,'Expense',  200.00, 'Projected meals - overnight trip',    '2026-04-19'),
(37, 15,NULL, 1, 'Revenue', 2200.00, 'Alumni game - higher turnout expected','2026-04-26'),
(38, 15,NULL, 2, 'Revenue',  600.00, 'Projected alumni donations at game',  '2026-04-26'),
(39, 15,NULL, 5, 'Expense',  300.00, 'Projected ref fees',                  '2026-04-26'),
(40, 15,NULL, 6, 'Expense',  420.00, 'Projected ice rental',                '2026-04-26'),
(41, 15,NULL, 10,'Expense',  300.00, 'Projected food and hospitality',      '2026-04-26'),

-- Practice projections
(42, NULL, 1,  6, 'Expense', 300.00, 'Projected ice rental - Jan 8',        '2026-01-08'),
(43, NULL, 1,  10,'Expense',  50.00, 'Projected snacks',                    '2026-01-08'),
(44, NULL, 5,  6, 'Expense', 275.00, 'Projected ice rental - Feb 3',        '2026-02-03'),
(45, NULL, 5,  10,'Expense',  50.00, 'Projected snacks',                    '2026-02-03'),
(46, NULL, 11, 6, 'Expense', 250.00, 'Projected ice rental - Mar 12',       '2026-03-12'),
(47, NULL, 11, 10,'Expense',  50.00, 'Projected snacks - Mar 12',           '2026-03-12'),
(48, NULL, 12, 6, 'Expense', 250.00, 'Projected ice rental - Mar 14',       '2026-03-14'),
(49, NULL, 12, 10,'Expense',  25.00, 'Projected snacks - Mar 14',           '2026-03-14'),
(50, NULL, 13, 6, 'Expense', 260.00, 'Projected ice rental - Mar 16',       '2026-03-16'),
(51, NULL, 13, 8, 'Expense',  60.00, 'Projected supplies - Mar 16',         '2026-03-16'),
(52, NULL, 14, 6, 'Expense', 285.00, 'Projected ice rental - Apr 2',        '2026-04-02'),
(53, NULL, 14, 10,'Expense',  45.00, 'Projected snacks - Apr 2',            '2026-04-02'),
(54, NULL, 15, 6, 'Expense', 295.00, 'Projected ice rental - Apr 9',        '2026-04-09'),
(55, NULL, 16, 6, 'Expense', 275.00, 'Projected ice rental - Apr 14',       '2026-04-14');

ALTER TABLE financial_projections AUTO_INCREMENT = 56;

-- =========================
-- ALUMNI TABLE
-- =========================
CREATE TABLE alumni (
    alumni_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    grad_year INT,
    position VARCHAR(100),
    phone VARCHAR(20),
    occupation VARCHAR(100),
    donation_status VARCHAR(50)
);

-- =========================
-- ALUMNI SEED DATA
-- =========================
INSERT INTO alumni (name, email, grad_year, position, phone, occupation, donation_status) VALUES
('Ethan Morales',    'ethan.morales@umd.edu',    2022, 'Forward',  '301-555-1122', 'Data Analyst',         'Donated'),
('Ryan Patel',       'ryan.patel@umd.edu',        2021, 'Defense',  '301-555-2233', 'Consultant',           'Donated'),
('Noah Kim',         'noah.kim@umd.edu',           2020, 'Goalie',   '301-555-3344', 'Software Engineer',    'Donated'),
('Lucas Bennett',    'lucas.bennett@umd.edu',      2019, 'Forward',  '301-555-4455', 'Sales Manager',        'Has Not Donated'),
('Daniel Cruz',      'daniel.cruz@umd.edu',        2018, 'Defense',  '301-555-5566', 'Project Coordinator',  'Has Not Donated'),
('Tyler Nguyen',     'tyler.nguyen.alum@gmail.com',2023, 'Forward',  '301-555-6677', 'Financial Analyst',    'Donated'),
('Jordan Brooks',    'jordan.brooks.alum@gmail.com',2022,'Defense',  '301-555-7788', 'Marketing Manager',    'Donated'),
('Marcus Webb',      'marcus.webb.alum@gmail.com', 2021, 'Forward',  '301-555-8899', 'Product Manager',      'Has Not Donated'),
('Sean Gallagher',   'sean.gallagher.alum@gmail.com',2020,'Goalie',  '301-555-9900', 'Physician Assistant',  'Donated'),
('Will Thornton',    'will.thornton.alum@gmail.com',2019,'Forward',  '301-555-0011', 'Attorney',             'Donated'),
('Patrick Doyle',    'patrick.doyle.alum@gmail.com',2018,'Defense',  '301-555-1234', 'Civil Engineer',       'Has Not Donated'),
('Alex Rivera',      'alex.rivera.alum@gmail.com', 2017, 'Forward',  '301-555-2345', 'Investment Banker',    'Donated'),
('Sam Kowalski',     'sam.kowalski.alum@gmail.com',2016, 'Defense',  '301-555-3456', 'High School Coach',    'Donated'),
('Brian Foster',     'brian.foster.alum@gmail.com',2015, 'Goalie',   '301-555-4567', 'Physical Therapist',   'Has Not Donated'),
('Colin Murphy',     'colin.murphy.alum@gmail.com',2023, 'Defense',  '301-555-5678', 'Accountant',           'Donated');

-- =========================
-- DONATIONS TABLE
-- =========================
CREATE TABLE donations (
    donation_id INT AUTO_INCREMENT PRIMARY KEY,
    alumni_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    donation_date DATE NOT NULL,
    message TEXT,
    FOREIGN KEY (alumni_id) REFERENCES alumni(alumni_id)
);

-- =========================
-- DONATIONS SEED DATA
-- =========================
INSERT INTO donations (alumni_id, amount, donation_date, message) VALUES
(1,  1500.00, '2026-03-28', 'Happy to support the team. Go Terps!'),
(2,  2000.00, '2026-03-29', 'Proud alum donation. Keep up the great work.'),
(3,   750.00, '2026-03-30', 'Keep it going! Best season in years.'),
(6,  1000.00, '2026-02-10', 'Glad to give back. Go Terps!'),
(7,   500.00, '2026-02-15', 'Small contribution but big support from me!'),
(9,  3000.00, '2026-01-20', 'Alumni game donation - hope to see everyone there.'),
(10, 1500.00, '2026-01-25', 'Always proud to support UMD hockey.'),
(12, 2500.00, '2026-03-05', 'Keep building the program!'),
(13,  800.00, '2026-03-10', 'Great memories from my time on the team.'),
(15,  600.00, '2026-04-01', 'First time donating - plan to keep it up!');

-- =========================
-- NEWSLETTERS TABLE
-- =========================
CREATE TABLE newsletters (
    newsletter_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- =========================
-- NEWSLETTERS SEED DATA
-- =========================
INSERT INTO newsletters (title, content, created_by) VALUES
('Spring Season Kickoff - January Update',
 'Dear Terps Hockey supporters, we are thrilled to kick off the spring semester with a strong roster and exciting schedule. Our first home game is January 10th against Georgetown. Come out and support the team! We have expanded seating and new merchandise available at the arena. Season tickets are still available - contact the athletic office for details.',
 1),
('February Game Recap and Upcoming Schedule',
 'What a month! We defeated Virginia Tech at home and had a tough road trip to Penn State. The team is playing hard and our defense has been outstanding. Coming up in February: home game against George Washington on Valentine\'s Day - bring your family and friends for a great night of hockey. Merchandise booth will be open two hours before puck drop.',
 2),
('Alumni Spotlight - Donate and Make a Difference',
 'This month we are highlighting our incredible alumni who have given back to the program. Thanks to your generosity we have been able to purchase new helmets, upgrade ice time, and support travel costs. If you have not yet donated this season, please consider a contribution of any size. Every dollar goes directly to supporting our student athletes.',
 1),
('Mid-Season Update - February 2026',
 'We are at the midpoint of our spring season with a 4-2-1 record. Highlights include our Valentine\'s Day shutout victory against GWU and a competitive road tie against Catholic University. The team has been putting in extra practice hours and it shows. Next home game is March 7th - see you at the rink!',
 2),
('March Stretch Run - Final Push Before Playoffs',
 'The team is in full swing with four games remaining before the postseason. Senior Night is March 28th vs Towson - join us as we honor our graduating players. There will be a post-game reception with alumni and families in the lobby. Reserve your tickets early as this game typically sells out.',
 1),
('Senior Night Recap and Spring Schedule Preview',
 'What an incredible night honoring our seniors! The team delivered a dominant 6-1 victory over Towson in front of a packed arena. Thank you to everyone who came out to show your support. Looking ahead, we have four exciting games in April and May. The alumni game on April 26th is shaping up to be a highlight of the year.',
 2),
('April Newsletter - Alumni Game Preview',
 'The annual alumni game is just around the corner on April 26th at UMD Ice Arena. We are expecting over 20 alumni to return and compete against the current roster. There will be a tailgate starting at 4pm, game at 6pm, and a reception after. All proceeds from ticket sales and donations go directly to the team equipment fund.',
 1);

-- =========================
-- EQUIPMENT / SUPPLIER MODULE
-- =========================
CREATE TABLE inventory_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    item_type ENUM('New', 'Used', 'Replacement') NOT NULL DEFAULT 'New',
    description VARCHAR(255),
    source VARCHAR(150),
    quantity INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 3,
    unit_cost DECIMAL(10,2) DEFAULT NULL,
    status ENUM('In Stock', 'Low Stock', 'Out of Stock') NOT NULL DEFAULT 'In Stock',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE equipment_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    supplier_user_id INT NOT NULL,
    quantity INT NOT NULL,
    order_status ENUM('New Order', 'In Progress', 'Shipped', 'Received', 'Cancelled') NOT NULL DEFAULT 'New Order',
    order_date DATE DEFAULT NULL,
    estimated_delivery_date DATE DEFAULT NULL,
    total_cost DECIMAL(10,2) DEFAULT NULL,
    customer_notes VARCHAR(255) DEFAULT NULL,
    vendor_notes VARCHAR(255) DEFAULT NULL,
    received_to_inventory BOOLEAN NOT NULL DEFAULT FALSE,
    created_by_user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES inventory_items(item_id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_user_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE RESTRICT
);

CREATE INDEX idx_inventory_category ON inventory_items(category);
CREATE INDEX idx_inventory_status ON inventory_items(status);
CREATE INDEX idx_equipment_orders_status ON equipment_orders(order_status);
CREATE INDEX idx_equipment_orders_supplier ON equipment_orders(supplier_user_id);

-- =========================
-- INVENTORY SEED DATA
-- =========================
INSERT INTO inventory_items
(item_id, item_name, category, item_type, description, source, quantity, reorder_level, unit_cost, status)
VALUES
(1,  'Red Bauer Helmet',       'Helmet',    'New',         'Primary varsity helmet',               'Team Supplier',      5,  3,  89.99,  'In Stock'),
(2,  'Home Jerseys',           'Jersey',    'Replacement', 'White game jerseys',                   'Campus Sports Store',12,  5,  65.00,  'In Stock'),
(3,  'Shoulder Pads',          'Pads',      'New',         'Senior and JV shoulder pads',          'Online Order',       2,  4,  74.50,  'Low Stock'),
(4,  'Practice Sticks',        'Stick',     'Used',        'Shared practice sticks',               'Team Supplier',      10, 4,  45.00,  'In Stock'),
(5,  'Away Jerseys',           'Jersey',    'Replacement', 'Dark road jerseys',                    'Campus Sports Store',8,  5,  65.00,  'In Stock'),
(6,  'Goalie Pads - Large',    'Pads',      'New',         'Full leg pad set for goalies',         'Online Order',       1,  2, 320.00,  'Low Stock'),
(7,  'Hockey Gloves',          'Gloves',    'New',         'Player gloves - medium and large mix', 'Team Supplier',      6,  4,  55.00,  'In Stock'),
(8,  'Skate Blades',           'Skates',    'Replacement', 'Replacement blades - standard size',   'Online Order',       3,  4,  28.00,  'Low Stock'),
(9,  'Puck Set (24-pack)',     'Equipment', 'New',         'Official game pucks',                  'Team Supplier',      4,  2,  36.00,  'In Stock'),
(10, 'Water Bottles (20-pack)','Equipment', 'New',         'Team water bottles with logo',         'Campus Sports Store',15, 5,  18.00,  'In Stock'),
(11, 'First Aid Kit',          'Medical',   'Replacement', 'Bench-side first aid kit',             'Online Order',       2,  2,  45.00,  'In Stock'),
(12, 'Stick Tape (36-roll)',   'Equipment', 'New',         'Black and white stick tape rolls',     'Team Supplier',      0,  3,  22.00,  'Out of Stock');

ALTER TABLE inventory_items AUTO_INCREMENT = 13;

-- =========================
-- EQUIPMENT ORDERS SEED DATA
-- =========================
INSERT INTO equipment_orders
(order_id, item_id, supplier_user_id, quantity, order_status, order_date, estimated_delivery_date, total_cost, customer_notes, vendor_notes, received_to_inventory, created_by_user_id)
VALUES
(1, 3,  4, 8,  'New Order',   '2026-04-10', NULL,         NULL,    'Need before next away game.',          NULL,                                FALSE, 1),
(2, 1,  4, 4,  'In Progress', '2026-04-08', '2026-04-18', 359.96,  'Match current helmet model.',          'Awaiting final shipping pickup.',   FALSE, 1),
(3, 2,  4, 15, 'Received',    '2026-04-01', '2026-04-07', 975.00,  'Practice jersey refresh.',             'Delivered and signed for.',         TRUE,  1),
(4, 12, 4, 6,  'New Order',   '2026-04-12', NULL,         NULL,    'Urgently needed - completely out.',    NULL,                                FALSE, 1),
(5, 8,  16,10, 'Shipped',     '2026-03-28', '2026-04-05', 280.00,  'Standard replacement blades.',        'Shipped via UPS ground.',           FALSE, 1),
(6, 6,  16,2,  'Received',    '2026-03-15', '2026-03-22', 640.00,  'New goalie pad set for spring.',       'Delivered and inspected - good.',   TRUE,  1),
(7, 7,  4, 8,  'Received',    '2026-02-20', '2026-02-28', 440.00,  'Gloves for new roster additions.',     'All delivered, sizes confirmed.',   TRUE,  1),
(8, 9,  16,4,  'Received',    '2026-01-10', '2026-01-17', 144.00,  'Pucks for spring season opener.',      'Received on time.',                 TRUE,  1);

ALTER TABLE equipment_orders AUTO_INCREMENT = 9;

-- =========================
-- SENT MESSAGES SEED DATA
-- =========================
INSERT INTO sent_messages (recipients, subject, body, sent_by) VALUES
('All Players',    'Spring Season Schedule Posted',         'Hey team, the full spring schedule is now live in the system. Check the schedule tab for all game and practice dates. First practice is January 8th. See you on the ice!', 2),
('All Players',    'Practice Reminder - January 13th',      'Reminder that practice is tomorrow Tuesday January 13th at 7pm at Community Ice Arena. Full equipment required. We will be working on power play and defensive zone coverage.', 2),
('All Players',    'Game Day - Georgetown January 10th',    'Game day reminder - tonight vs Georgetown at UMD Ice Arena. Doors open at 6pm, puck drop at 7:30pm. Please arrive by 6pm for warmups. Bring your student ID for team check-in.', 1),
('All Players',    'PSU Road Trip Details',                  'For the Penn State away game on Feb 7th - bus departs UMD South Campus at 9am sharp. Bring snacks and be prepared for a 3 hour ride. Hotel info has been emailed separately.', 2),
('Offense Players','Offensive Zone Drill Review',            'Offense group - please watch the video I shared in the team GroupMe before our next practice. We will be running the new breakout drill and I want everyone familiar with their assignments.', 2),
('All Players',    'Senior Night - March 28th',             'Mark your calendars - Senior Night is March 28th vs Towson. This is a special evening honoring our graduating players. Please invite family and friends. There will be a post-game reception in the lobby.', 1),
('All Players',    'April Schedule and Alumni Game Info',   'April schedule is finalized. Please note the alumni game on April 26th - all current players are expected to participate. This is a huge event for program fundraising and alumni relations.', 1),
('Defense Players','Defensive Zone Coverage - Film Session', 'Defense group - mandatory film session this Thursday at 5pm in the athletic conference room before practice. We will review coverage breakdowns from the Navy away game.', 2);

-- =========================
-- NEWSLETTER SUBSCRIBERS TABLE
-- =========================
CREATE TABLE subscribers (
    subscriber_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    date_added DATE NOT NULL,
    status ENUM('Active', 'Pending', 'Inactive') NOT NULL DEFAULT 'Active'
);

-- =========================
-- SUBSCRIBERS SEED DATA
-- =========================
INSERT INTO subscribers (email, date_added, status) VALUES
('fan1@email.com',            '2026-01-15', 'Active'),
('alumni1@email.com',         '2026-02-02', 'Active'),
('supporter@email.com',       '2026-02-18', 'Active'),
('familymember@email.com',    '2026-03-01', 'Pending'),
('hockeymom22@gmail.com',     '2026-01-08', 'Active'),
('terps4ever@yahoo.com',      '2026-01-10', 'Active'),
('umd_proud@hotmail.com',     '2026-01-12', 'Active'),
('icehockey_fan@gmail.com',   '2026-01-20', 'Active'),
('goterps2026@gmail.com',     '2026-02-05', 'Active'),
('supportermd@gmail.com',     '2026-02-10', 'Active'),
('rinkside_fan@gmail.com',    '2026-02-14', 'Active'),
('terrapinfan@outlook.com',   '2026-02-20', 'Pending'),
('alumni_2019@gmail.com',     '2026-03-01', 'Active'),
('maryland_hockey@gmail.com', '2026-03-05', 'Active'),
('puckdrop@gmail.com',        '2026-03-10', 'Active'),
('icearena_regular@gmail.com','2026-03-15', 'Active'),
('family_section@gmail.com',  '2026-03-18', 'Active'),
('boosterclub@umd.edu',       '2026-03-20', 'Active'),
('terps_superfan@gmail.com',  '2026-03-25', 'Active'),
('hockey_parent@gmail.com',   '2026-04-01', 'Active');
