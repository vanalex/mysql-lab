#!/usr/bin/env python3
"""Generate the large people.sql seed file locally.

The output is intentionally ignored by Git. Run this script whenever you need
to recreate the local MySQL seed data.
"""

from __future__ import annotations

import argparse
import random
from datetime import date, timedelta
from pathlib import Path


FIRST_NAMES = [
    "Aaron", "Adam", "Alex", "Amber", "Andrea", "Ashley", "Bill", "Brenda",
    "Brittany", "Calvin", "Christina", "Christine", "Craig", "Cynthia",
    "David", "Deborah", "Edward", "Elizabeth", "Emily", "Ethan", "Grant",
    "Gregory", "Heather", "Heidi", "Hector", "James", "Jane", "Jason",
    "Jennifer", "Jeremy", "Jessica", "John", "Joseph", "Joshua", "Judith",
    "Judy", "Juan", "Kaitlyn", "Kayla", "Keith", "Kelly", "Kevin",
    "Kimberly", "Kurt", "Linda", "Lisa", "Lorraine", "Maria", "Mary",
    "Matthew", "Megan", "Michael", "Michelle", "Mitchell", "Patricia",
    "Rebecca", "Rebekah", "Robert", "Roger", "Sabrina", "Scott", "Shane",
    "Stacey", "Stephen", "Tamara", "Thomas", "Timothy", "Tina", "Traci",
    "Tyler", "Vanessa", "Veronica", "Victoria", "Walter", "William",
]

LAST_NAMES = [
    "Alexander", "Allen", "Barrett", "Bass", "Berry", "Bridges", "Brown",
    "Burton", "Campbell", "Carey", "Chapman", "Craig", "Cruz", "Davis",
    "Edwards", "Flores", "Foster", "Galvan", "Gilbert", "Gomez", "Gonzalez",
    "Hall", "Harris", "Henson", "Higgins", "Howard", "Hughes", "Hunter",
    "James", "Jefferson", "Johnson", "Kelly", "Lawrence", "Le", "Leon",
    "Lewis", "Little", "Lopez", "Love", "Lucero", "Marquez", "Martinez",
    "Maxwell", "May", "Mccoy", "Orozco", "Owens", "Park", "Patel",
    "Patterson", "Payne", "Perez", "Perkins", "Powers", "Prince", "Ramos",
    "Reyes", "Rice", "Ross", "Russell", "Sanchez", "Shepherd", "Smith",
    "Stephens", "Stewart", "Tapia", "Terry", "Travis", "Turner",
    "Valenzuela", "Walker", "Wallace", "Walters", "Ward", "Watkins", "Webb",
    "White", "Williams", "Wong", "Wright", "Young", "Zhang",
]

STATES = ["AZ", "CA", "CO", "FL", "IL", "MA", "NC", "NY", "TX", "WA"]

BIO_WORDS = [
    "ability", "able", "account", "across", "action", "address", "adult",
    "agency", "agreement", "ahead", "analysis", "animal", "another",
    "approach", "area", "artist", "available", "bank", "base", "beat",
    "beautiful", "begin", "behavior", "believe", "benefit", "billion",
    "blood", "board", "born", "break", "build", "business", "camera",
    "campaign", "candidate", "capital", "career", "carry", "catch", "cause",
    "center", "central", "century", "chair", "challenge", "chance", "change",
    "character", "charge", "choice", "church", "citizen", "city", "claim",
    "class", "clear", "close", "cold", "college", "collection", "commercial",
    "common", "community", "company", "compare", "computer", "concern",
    "condition", "conference", "consumer", "continue", "cost", "country",
    "course", "court", "create", "culture", "current", "customer", "dark",
    "daughter", "debate", "decade", "decide", "defense", "degree", "detail",
    "develop", "development", "difference", "dinner", "direction", "director",
    "discover", "discussion", "doctor", "door", "down", "dream", "drive",
    "economic", "education", "effect", "effort", "energy", "enjoy",
    "environment", "especially", "establish", "evening", "evidence", "every",
    "exactly", "executive", "exist", "expect", "experience", "expert", "face",
    "fact", "factor", "family", "father", "fear", "federal", "feel", "field",
    "figure", "film", "final", "financial", "find", "fine", "fire", "floor",
    "focus", "follow", "food", "foot", "force", "foreign", "forget", "former",
    "forward", "friend", "front", "full", "fund", "future", "game", "garden",
    "general", "give", "glass", "goal", "good", "government", "great",
    "ground", "group", "growth", "guess", "half", "happen", "hard", "head",
    "health", "hear", "heart", "heavy", "history", "hold", "home", "hope",
    "hospital", "hotel", "hour", "house", "human", "hundred", "husband",
    "identify", "image", "important", "improve", "include", "including",
    "increase", "indicate", "individual", "industry", "information", "inside",
    "institution", "international", "interview", "investment", "involve",
    "issue", "itself", "kitchen", "know", "language", "large", "later", "law",
    "lead", "leader", "learn", "least", "left", "level", "life", "light",
    "line", "list", "listen", "local", "long", "look", "lose", "loss", "lot",
    "major", "manage", "management", "many", "market", "marriage", "material",
    "matter", "maybe", "measure", "medical", "meeting", "member", "memory",
    "mention", "message", "method", "middle", "million", "mind", "minute",
    "mission", "model", "modern", "moment", "money", "morning", "mother",
    "mouth", "move", "movement", "movie", "music", "natural", "necessary",
    "network", "news", "newspaper", "night", "none", "north", "notice",
    "number", "office", "officer", "official", "often", "operation", "order",
    "organization", "owner", "painting", "paper", "parent", "participant",
    "partner", "party", "pass", "pattern", "peace", "people", "perform",
    "person", "physical", "piece", "place", "plan", "plant", "play", "policy",
    "political", "politics", "popular", "population", "position", "positive",
    "possible", "practice", "prepare", "pressure", "prevent", "probably",
    "product", "professional", "program", "project", "property", "protect",
    "prove", "public", "purpose", "question", "quickly", "radio", "raise",
    "range", "rate", "reach", "ready", "real", "realize", "reason", "receive",
    "recognize", "record", "reflect", "region", "relate", "relationship",
    "remember", "represent", "require", "research", "resource", "rest",
    "result", "return", "reveal", "rich", "rise", "risk", "road", "rock",
    "role", "safe", "scene", "school", "science", "score", "season", "seat",
    "second", "security", "seek", "sell", "senior", "series", "serve",
    "service", "shake", "shoulder", "sign", "significant", "similar", "simple",
    "simply", "single", "sister", "site", "situation", "skill", "skin", "small",
    "smile", "society", "soldier", "somebody", "song", "sound", "source",
    "south", "southern", "special", "specific", "speech", "spend", "sport",
    "spring", "stage", "stand", "star", "start", "state", "statement",
    "station", "stock", "stop", "store", "strategy", "street", "structure",
    "student", "study", "subject", "successful", "suddenly", "suggest",
    "support", "surface", "teacher", "team", "technology", "television",
    "term", "than", "theory", "thing", "think", "third", "though", "thousand",
    "threat", "throw", "today", "together", "total", "town", "trade",
    "traditional", "training", "treatment", "tree", "trial", "truth", "unit",
    "until", "upon", "usually", "voice", "vote", "wait", "walk", "wall",
    "want", "war", "watch", "water", "wear", "week", "western", "white",
    "whole", "whose", "wind", "window", "wish", "within", "without", "woman",
    "word", "work", "world", "worry", "writer", "wrong", "yard", "yeah",
    "young",
]


SCHEMA = """CREATE DATABASE IF NOT EXISTS `{database}`
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE `{database}`;

DROP TABLE IF EXISTS `people`;

CREATE TABLE `people` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `first_name` VARCHAR(80) NOT NULL,
    `last_name` VARCHAR(80) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `birthday` DATE NOT NULL,
    `state` CHAR(2) NOT NULL,
    `bio` TEXT NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_people_email` (`email`),
    KEY `idx_people_first_name` (`first_name`),
    KEY `idx_people_state` (`state`),
    KEY `idx_people_birthday` (`birthday`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
"""


def sql_string(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
    )
    return f"'{escaped}'"


def random_birthday(rng: random.Random) -> str:
    start = date(1935, 1, 1)
    end = date(2008, 12, 31)
    days = (end - start).days
    return (start + timedelta(days=rng.randint(0, days))).isoformat()


def random_sentence(rng: random.Random) -> str:
    length = rng.randint(5, 12)
    words = rng.choices(BIO_WORDS, k=length)
    words[0] = words[0].capitalize()
    return " ".join(words) + "."


def random_bio(rng: random.Random) -> str:
    paragraphs = []
    for _ in range(rng.randint(1, 4)):
        sentence_count = rng.randint(1, 3)
        paragraphs.append(" ".join(random_sentence(rng) for _ in range(sentence_count)))
    return "\n".join(paragraphs)


def person_row(index: int, rng: random.Random) -> str:
    first_name = rng.choice(FIRST_NAMES)
    last_name = rng.choice(LAST_NAMES)
    email = f"{first_name.lower()}.{last_name.lower()}.{index}@example.com"
    values = [
        first_name,
        last_name,
        email,
        random_birthday(rng),
        rng.choice(STATES),
        random_bio(rng),
    ]
    return "(" + ", ".join(sql_string(value) for value in values) + ")"


def write_people_sql(path: Path, database: str, rows: int, batch_size: int, seed: int) -> None:
    rng = random.Random(seed)
    with path.open("w", encoding="utf-8", newline="\n") as file:
        file.write(SCHEMA.format(database=database))

        for batch_start in range(0, rows, batch_size):
            batch_end = min(batch_start + batch_size, rows)
            file.write("\nINSERT INTO `people` (`first_name`, `last_name`, `email`, `birthday`, `state`, `bio`) VALUES\n")
            for index in range(batch_start, batch_end):
                ending = ";\n" if index == batch_end - 1 else ",\n"
                file.write(person_row(index, rng) + ending)


def positive_int(value: str) -> int:
    number = int(value)
    if number <= 0:
        raise argparse.ArgumentTypeError("value must be greater than zero")
    return number


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate the local people.sql MySQL seed file.")
    parser.add_argument("-o", "--output", default="people.sql", type=Path, help="output SQL file")
    parser.add_argument("-n", "--rows", default=1_000_000, type=positive_int, help="number of people rows")
    parser.add_argument("--database", default="mysql-lab", help="database name to create/use")
    parser.add_argument("--batch-size", default=1_000, type=positive_int, help="rows per INSERT statement")
    parser.add_argument("--seed", default=42, type=int, help="random seed for deterministic output")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    write_people_sql(
        path=args.output,
        database=args.database,
        rows=args.rows,
        batch_size=args.batch_size,
        seed=args.seed,
    )
    print(f"Wrote {args.rows:,} rows to {args.output}")


if __name__ == "__main__":
    main()
