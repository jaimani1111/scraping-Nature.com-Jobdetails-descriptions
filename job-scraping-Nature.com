import pandas as pd
import requests
from bs4 import BeautifulSoup 

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36 Edg/125.0.0.0'}

# URL to scrape
url = 'https://www.nature.com/naturecareers/jobs/computing/#browsing'

# Make a request to the URL
r = requests.get(url, headers=headers)
if r.status_code != 200:
    print(f"Failed to retrieve the webpage. Status code: {r.status_code}")
else:
    # Parse the HTML content
    soup = BeautifulSoup(r.text, "lxml")

    # Print the entire HTML content to inspect it
    print(soup.prettify())

    # Lists to store job details
    job_titles = []
    job_descriptions = []
    job_salary = []
    job_locations =[]

    # Extracting job titles
    job_title_elements = soup.find_all('h3', class_='lister__header')
    print(f"Found {len(job_title_elements)} job title elements.")
    for element in job_title_elements:
        print(element)  # Print each element to debug
        job_title = element.text.strip()
        job_titles.append(job_title)

    # Extracting job descriptions
    job_description_elements = soup.find_all('p', class_='lister__description js-clamp-2')
    print(f"Found {len(job_description_elements)} job description elements.")
    for element in job_description_elements:
        print(element)  # Print each element to debug
        job_description = element.text.strip()
        job_descriptions.append(job_description)
        
    job_salary_elements = soup.find_all('li', class_ = 'lister__meta-item lister__meta-item--salary')
    print(f"Found {len(job_salary_elements)} job salary elements.")
    for element in job_salary_elements:
        print(element)
        job_salarys = element.text.strip()
        job_salary.append(job_salarys)
     
    job_location_elements = soup.find_all('li', class_='lister__meta-item lister__meta-item--location')
    print(f"Found {len(job_location_elements)} job location elements.")
    for element in job_location_elements:
        print(element)  # Print each element to debug
        job_location = element.text.strip()
        job_locations.append(job_location)
    # Creating DataFrame
    min_length = min(len(job_titles), len(job_locations), len(job_descriptions), len(job_salary))
    df = pd.DataFrame({
        "job_title": job_titles[:min_length],
        "job_location": job_locations[:min_length],
        "job_description": job_descriptions[:min_length],
        "job_salary": job_salary[:min_length]
    })

    # Printing the DataFrame
    print(df)

    # Saving to CSV
    df.to_csv("jobs1.csv", index=False)
    print("done")
