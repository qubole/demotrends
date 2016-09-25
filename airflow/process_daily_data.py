from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.contrib.operators.qubole_operator import QuboleOperator
from datetime import datetime, timedelta


default_args = {
    'owner': 'airflow',
    'depends_on_past': True,
    'start_date': datetime(2016, 8, 1),
    'end_date': datetime(2016, 8, 5)
    'email': ['airflow@qubole.com'],
    'email_on_failure': False,
    'email_on_retry': False
}

dag = DAG('process_daily_data', default_args=default_args, schedule_interval='@daily')

def_loc = 's3://BUCKET/DEF_LOC'


t1 = QuboleOperator(
    task_id='fetch_pagecount_data',
    command_type="shellcmd",
    script="wget -r https://dumps.wikimedia.org/other/pagecounts-raw/{{ ds.split('-')[0] }}/{{ '{0}-{1}'.format(ds.split('-')[0], ds.split('-')[1]) }} \
            -P pagecounts/{{ ds }} -A pagecounts-{{ macros.ds_format(ds, '%%Y-%%m-%%d', '%%Y%%m%%d') }}-*.gz; \
            s3cmd -c /usr/lib/hustler/s3cfg sync pagecounts/{{ ds }} %s/wikitrends/pagecounts/"%(def_loc),
    dag=dag)

t2 = QuboleOperator(
    task_id='create_pagecount_table',
    command_type="hivecmd",
    query= "CREATE EXTERNAL TABLE IF NOT EXISTS pagecounts (`group` STRING, page_title STRING, `views` BIGINT, bytes_sent BIGINT) \
            PARTITIONED BY (`date` STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY ' ' LOCATION '{0}/demotrends/pagecounts/'; \
            ALTER TABLE pagecounts recover partitions;".
        format(def_loc),
    dag=dag)

t3 = QuboleOperator(
    task_id='create_filtered_pagecounts_table',
    command_type="hivecmd",
    query= "CREATE TABLE IF NOT EXISTS filtered_pagecounts (page_title STRING, `views` BIGINT, bytes_sent BIGINT)\
            PARTITIONED BY (`date` STRING);",
    dag=dag)

t4 = QuboleOperator(
    task_id='create_normalized_pagecounts_table',
    command_type="hivecmd",
    query= "CREATE TABLE IF NOT EXISTS normalized_pagecounts (page_id BIGINT, page_title STRING, page_url STRING, `views` BIGINT, bytes_sent BIGINT)\
            PARTITIONED BY (`date` STRING);",
    dag=dag)

t5 = QuboleOperator(
    task_id='populate_filtered_pagecounts',
    command_type="hivecmd",
    query="FROM pagecounts pvs \
           INSERT OVERWRITE TABLE filtered_pagecounts PARTITION(`date`='{{ ds }}') \
           SELECT regexp_replace (reflect ('java.net.URLDecoder','decode', reflect ('java.net.URLDecoder','decode',pvs.page_title)),'^\s*([a-zA-Z0-9]+).*','$1') page_title \
                ,SUM (pvs.views) AS total_views, SUM (pvs.bytes_sent) AS total_bytes_sent \
           WHERE not pvs.page_title RLIKE '(MEDIA|SPECIAL||Talk|User|User_talk|Project|Project_talk|File|File_talk|MediaWiki|MediaWiki_talk|Template|Template_talk|Help|Help_talk|Category|Category_talk|Portal|Wikipedia|Wikipedia_talk|upload|Special)\:(.*)' and \
                pvs.page_title RLIKE '^([A-Z])(.*)' and \
                not pvs.page_title RLIKE '(.*).(jpg|gif|png|JPG|GIF|PNG|txt|ico)$' and \
                pvs.page_title <> '404_error/' and \
                pvs.page_title <> 'Main_Page' and \
                pvs.page_title <> 'Hypertext_Transfer_Protocol' and \
                pvs.page_title <> 'Favicon.ico' and \
                pvs.page_title <> 'Search' and \
                pvs.`date` = '{{ ds }}' \
          GROUP BY \
                regexp_replace (reflect ('java.net.URLDecoder','decode', reflect ('java.net.URLDecoder','decode',pvs.page_title)),'^\s*([a-zA-Z0-9]+).*','$1');",
    dag=dag)

t6 = QuboleOperator(
    task_id='populate_normalized_pagecounts',
    command_type="hivecmd",
    query="INSERT overwrite table normalized_pagecounts partition(`date`='{{ ds }}') \
           SELECT pl.page_id page_id, REGEXP_REPLACE(pl.true_title, '_', ' ') page_title, pl.true_title page_url, views, bytes_sent \
           FROM page_lookup pl JOIN filtered_pagecounts fp \
           ON fp.page_title = pl.redirect_title where fp.`date`='{{ ds }}';",
    dag=dag)

t1.set_downstream(t2)
t1.set_downstream(t3)
t1.set_downstream(t4)
t5.set_upstream(t2)
t5.set_upstream(t3)
t6.set_upstream(t4)
t6.set_upstream(t5)

