import mysql.connector
import os
import time


db_config = {
    'user': 'root',
    'password': 'A@ron123',
    'host': '127.0.0.1',
    'database': 'bronze',
    'allow_local_infile': True
}

files = [
    ('crm_cust_info', 'cust_info.csv', 'source_crm'),
    ('crm_prd_info', 'prd_info.csv', 'source_crm'),
    ('crm_sales_details', 'sales_details.csv', 'source_crm'),
    ('erp_cust_az12', 'CUST_AZ12.csv', 'source_erp'),
    ('erp_loc_a101', 'LOC_A101.csv', 'source_erp'),
    ('erp_px_cat_g1v2', 'PX_CAT_G1V2.csv', 'source_erp')
]

base_path = r"C:\\Users\\AARON\\Documents\\Dev\\Databases\\Projetos\\sql-data-warehouse-project\\datasets"

try:
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()

    cursor.execute('SET GLOBAL local_infile = 1;')
    
    beginning = time.time()
    print('Iniciando o carregamento dos dados...\n')

    # Data Ingestion
    for table, filename, folder in files:
        print(f"Carregando {table}...")

        file_path = os.path.join(base_path, folder, filename).replace('\\', '/')

        cursor.execute(f'TRUNCATE TABLE {table};')
        query = f"""
          LOAD DATA LOCAL INFILE '{file_path}'
          INTO TABLE {table}
          FIELDS TERMINATED BY ','
          LINES TERMINATED BY '\\r\\n'
          IGNORE 1 ROWS; 
        """

        cursor.execute(query)
        conn.commit()
        print(f"Sucesso: {table}")
        print('-' * 40)
    
    end = time.time()
    total_time = end - beginning 

    print(f'Os dados foram carregados com sucesso em {total_time:.2f} segundos.')


except mysql.connector.Error as err:
    print(f"Erro: {err}")

finally:
    if cursor:
        cursor.close()
    if conn:
        conn.close()
