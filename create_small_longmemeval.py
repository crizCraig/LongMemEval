#!/usr/bin/env python3

import json
import uuid
from typing import List, Dict, Any

def create_sample_conversation(topic: str, user_content: str, assistant_content: str) -> List[Dict[str, str]]:
    """Create a sample conversation with role and content."""
    return [
        {
            "role": "user",
            "content": user_content
        },
        {
            "role": "assistant", 
            "content": assistant_content
        }
    ]

def generate_sample_data() -> List[Dict[str, Any]]:
    """Generate sample data with 2 questions following the longmemeval_s.json structure."""
    
    # First question
    question1 = {
        "question_id": str(uuid.uuid4())[:8],
        "question_type": "single-session-user",
        "question": "What programming language did I use for my first project?",
        "answer": "Python",
        "question_date": "2023/06/15 (Thu) 14:30",
        "haystack_dates": [
            "2023/06/10 (Sat) 09:15",
            "2023/06/12 (Mon) 16:45",
            "2023/06/14 (Wed) 11:20"
        ],
        "haystack_session_ids": [
            "session_001",
            "session_002", 
            "session_003"
        ],
        "haystack_sessions": [
            create_sample_conversation(
                "programming_start",
                "I'm thinking about learning to code. What language should I start with for my first project?",
                "Python is an excellent choice for beginners! It has clean syntax and is very readable. You can use it for web development, data analysis, automation, and much more. I'd recommend starting with Python for your first programming project."
            ),
            create_sample_conversation(
                "project_planning",
                "I've decided to go with Python for my first programming project. Can you help me think of a good beginner project?",
                "Great choice! For a first Python project, I'd suggest starting with something like a simple calculator, a to-do list app, or a basic web scraper. These projects will help you learn fundamental concepts like variables, functions, loops, and file handling."
            ),
            create_sample_conversation(
                "project_progress",
                "I'm making good progress on my Python project! It's really fun to see the code come together.",
                "That's wonderful to hear! Python is known for being beginner-friendly, and it sounds like you're experiencing that firsthand. Keep practicing and experimenting - that's the best way to improve your programming skills."
            )
        ],
        "answer_session_ids": [
            "answer_session_001"
        ]
    }
    
    # Second question  
    question2 = {
        "question_id": str(uuid.uuid4())[:8],
        "question_type": "single-session-user", 
        "question": "What type of cuisine did I cook for my dinner party last month?",
        "answer": "Italian",
        "question_date": "2023/06/20 (Tue) 19:45",
        "haystack_dates": [
            "2023/05/18 (Thu) 15:30",
            "2023/05/22 (Mon) 12:15",
            "2023/05/25 (Thu) 18:00"
        ],
        "haystack_session_ids": [
            "session_004",
            "session_005",
            "session_006"
        ],
        "haystack_sessions": [
            create_sample_conversation(
                "dinner_party_planning",
                "I'm planning a dinner party for next month and want to cook something special. Any cuisine recommendations?",
                "For a dinner party, Italian cuisine is always a crowd-pleaser! You could make homemade pasta with marinara sauce, garlic bread, and tiramisu for dessert. Italian food is comfort food that most people love, and it's great for sharing."
            ),
            create_sample_conversation(
                "menu_planning",
                "I've decided to go with Italian for my dinner party! Can you help me plan a complete menu?",
                "Perfect choice! For an Italian dinner party, you could start with bruschetta or a caprese salad, serve homemade fettuccine alfredo or spaghetti carbonara as the main course, with garlic bread and a simple side salad. For dessert, tiramisu or panna cotta would be wonderful."
            ),
            create_sample_conversation(
                "shopping_prep",
                "I'm going shopping for ingredients for my Italian dinner party tomorrow. The menu looks amazing!",
                "How exciting! Make sure to get good quality ingredients - fresh basil, real parmesan cheese, and good olive oil will make a big difference. Don't forget wine for cooking and serving. Your guests are going to love the Italian feast you're preparing!"
            )
        ],
        "answer_session_ids": [
            "answer_session_002"
        ]
    }
    
    return [question1, question2]

def main():
    """Main function to generate and save the sample JSON file."""
    print("Generating sample longmemeval data with 2 questions...")
    
    # Generate the sample data
    sample_data = generate_sample_data()
    
    # Output filename
    output_file = "/Users/craigquiter/src/LongMemEval/data/longmemeval_small.json"
    
    # Save to JSON file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(sample_data, f, indent=2, ensure_ascii=False)
    
    print(f"Successfully created {output_file}")
    print(f"Generated {len(sample_data)} questions")
    
    # Print a summary
    for i, item in enumerate(sample_data, 1):
        print(f"\nQuestion {i}:")
        print(f"  ID: {item['question_id']}")
        print(f"  Question: {item['question']}")
        print(f"  Answer: {item['answer']}")
        print(f"  Haystack sessions: {len(item['haystack_sessions'])}")

if __name__ == "__main__":
    main()
