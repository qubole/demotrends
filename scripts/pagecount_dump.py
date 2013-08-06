#!/usr/bin/python
from calendar import monthrange
import requests
import sys
from optparse import OptionParser
import subprocess
from datetime import date, timedelta

def download_url(url, path):
  print "Downloading %s to %s" % (url, path)
  r = requests.get(url, stream=True)
  print "Total size is: %s" % (r.headers['content-length'])
  total = int(r.headers['content-length'])
  progress = 0
  downloaded = 0
  chunk_size = 1048576
  if r.status_code == 200:
    with open(path, 'wb') as f:
      for chunk in r.iter_content(chunk_size):
        f.write(chunk)
        downloaded += chunk_size
        current_progress = (downloaded * 100 / total ) % 10
        if current_progress > progress:
          progress = current_progress
          sys.stdout.write('#')
          sys.stdout.flush()
  sys.stdout.write('\n')

def upload_file_to_s3(path, s3_url):
  subprocess.check_call(["s3cmd", "-c", "/usr/lib/hustler/creds/s3cfg", "sync", "%s/" % path, s3_url])

def cleanup(path):
  subprocess.check_call(["rm", "-r", path])
  
def process_day(year, month, day, temp_loc):
  dump_url = "http://dumps.wikimedia.org/other/pagecounts-raw/%d/%d-%02d/pagecounts-%02d%02d%02d-%02d0000.gz"
  temp = "%s/pagecounts-%02d0000.gz"
  temp_dir = "%s/%d-%02d-%02d" % (temp_loc, year, month, day)
  subprocess.check_call(["mkdir", "-p", temp_dir])
  for hour in range(0, 24):
    url = dump_url % (year, year, month, year, month, day,hour)
    file = temp % (temp_dir, hour)
    download_url(url, file)

def main(year, month, day, temp_loc, s3_loc):
  numdays = monthrange(year, month)[1] + 1
  process_day(year, month, day, temp_loc)
  upload_file_to_s3(temp_loc, s3_loc)
  cleanup(temp_loc)

parser = OptionParser()
parser.add_option("-y", "--year", dest="year", help = "Download files for this year")
parser.add_option("-m", "--month", dest="month", help = "Download files for this month")
parser.add_option("-d", "--day",  dest="day", help = "Download files for this day")
parser.add_option("-t", "--temp", dest="temp_loc", help = "Temp location in local filesytem")
parser.add_option("-s", "--s3", dest="s3url", help = "S3 location")
(options, args) = parser.parse_args()
now = date.today() - timedelta(days=1)
year = now.year
month = now.month
day = now.day

if not options.year is None:
  year = int(options.year)
if not options.month is None:
  month = int(options.month)
if not options.day is None:
  day = int(options.day)


main(year, month, day, options.temp_loc, options.s3url)
