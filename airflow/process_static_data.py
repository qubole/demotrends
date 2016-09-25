from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.contrib.operators.qubole_operator import QuboleOperator
from datetime import datetime, timedelta


seven_days_ago = datetime.combine(datetime.today() - timedelta(7),
                                  datetime.min.time())

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': seven_days_ago,
    'email': ['airflow@qubole.com'],
    'email_on_failure': False,
    'email_on_retry': False
}

dag = DAG('process_static_data', default_args=default_args, schedule_interval='@once')

t1 = QuboleOperator(
    task_id='create_page_table',
    command_type='hivecmd',
    query="DROP TABLE if exists page;\
          CREATE EXTERNAL TABLE page (page_id BIGINT, page_latest BIGINT, page_title STRING)\
          ROW FORMAT DELIMITED FIELDS TERMINATED BY '\001' \
          LOCATION 's3n://paid-qubole/default-datasets/demotrends/page/';",
    dag=dag)

t2 = QuboleOperator(
    task_id='create_redirect_table',
    command_type='hivecmd',
    query="DROP TABLE if exists redirect;\
          CREATE EXTERNAL TABLE redirect( rd_from BIGINT, page_title STRING) \
          ROW FORMAT DELIMITED FIELDS TERMINATED BY '\001' \
          LOCATION 's3n://paid-qubole/default-datasets/demotrends/redirect/';",
    dag=dag)

join = DummyOperator(
    task_id='join',
    dag=dag
)

t3 = QuboleOperator(
    task_id='create_page_lookup_nonredirect',
    command_type='hivecmd',
    query= "DROP TABLE if exists page_lookup_nonredirect; \
            CREATE TABLE page_lookup_nonredirect (redirect_id bigint, redirect_title STRING, true_title STRING, page_id BIGINT, page_version BIGINT);\
            INSERT OVERWRITE TABLE page_lookup_nonredirect \
            SELECT  page.page_id as redircet_id, page.page_title as redirect_title, page.page_title true_title, \
                    page.page_id, page.page_latest \
            FROM page LEFT OUTER JOIN redirect ON page.page_id = redirect.rd_from \
            WHERE redirect.rd_from IS NULL;",
    dag=dag)

t4 = QuboleOperator(
    task_id='create_page_lookup_redirect',
    command_type='hivecmd',
    query= "DROP TABLE if exists page_lookup_redirect; \
            CREATE TABLE page_lookup_redirect (redirect_id bigint, redirect_title STRING, true_title STRING, page_id BIGINT, page_version BIGINT); \
            insert overwrite table page_lookup_redirect \
            select original_page.page_id redirect_id, original_page.page_title redirect_title, \
                    final_page.page_title as true_title, final_page.page_id, final_page.page_latest \
            from page final_page join redirect on (redirect.page_title = final_page.page_title) \
                join page original_page on (redirect.rd_from = original_page.page_id);",
    dag=dag)

t5 = QuboleOperator(
    task_id='create_page_lookup',
    command_type='hivecmd',
    query= "DROP TABLE if exists page_lookup; \
            CREATE TABLE page_lookup (redirect_id bigint, redirect_title STRING, true_title STRING, page_id BIGINT, page_version BIGINT); \
            INSERT OVERWRITE TABLE page_lookup \
            SELECT redirect_id, redirect_title, true_title, page_id, page_version \
            FROM ( \
                SELECT redirect_id, redirect_title, true_title, page_id, page_version \
                FROM page_lookup_nonredirect \
                UNION ALL \
                SELECT redirect_id, redirect_title, true_title, page_id, page_version \
                FROM page_lookup_redirect \
            ) u;",
    dag=dag)

t1.set_downstream(join)
t2.set_downstream(join)
join.set_downstream(t3)
join.set_downstream(t4)
t3.set_downstream(t5)
t4.set_downstream(t5)


