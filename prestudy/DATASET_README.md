# SMC IC Dataset

## Structure

[
    {
        "title" : "title1",
        "date": "date1",
        "keywords": ["keyword1", "keyword2", ...],
        "intro": {
                "arrow_points": ["point1", "point2", ...],
                "intro_text": ["text1", "text2", ...]
            },
        "overview": [
                "text1", "text2", ...
            ],
        "statements": [
                {
                    "expert": "title expert 1 / name expert 1", 
                    "description": "description expert 1", 
                    "statements": [
                        {"type": "heading1|paragraph1", "text": "statement1 or heading1 text"}
                        {"type": "heading2|paragraph2", "text": "statement2 or heading2 text"}
                        ...
                    ]
                },
                ...
            ], 
        "primary_source": [
                {
                    "source": "source1",
                    "link": "link1"
                }
                ...
            ],
        "background_information": [
                "text1", "text2" ...
            ],
        "glossary": [
                {
                    "word": "word1",
                    "definition: "definition1"
                }
                ...
            ],
        "literature": {
            "experts": [
                    {
                        "source": "source1",
                        "link": "link1"
                    }
                    ...
                ],
            "smc": [
                    {
                        "source": "source1",
                        "link": "link1"
                    }
                    ...
                ],
            "further": [
                    {
                        "source": "source1",
                        "link": "link1"
                    }
                    ...
                ],
        }
    } 
]