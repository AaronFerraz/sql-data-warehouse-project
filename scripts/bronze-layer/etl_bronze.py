import pandas as pd
from sqlalchemy import create_engine, text
import os
import time
from urllib.parse import quote_plus


senha_bruta = 'A@ron123'
senha_codificada = quote_plus(senha_bruta) # Transforma o @ em %40

engine = create_engine(f'mysql+mysqlconnector://root:{senha_codificada}@127.0.0.1/bronze')

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
    beginning = time.time()
    print('Iniciando o carregamento dos dados...\n')

    # Data Ingestion
    with engine.connect() as conn:

        for table, filename, folder in files:
            print(f"Carregando {table}...")

            file_path = os.path.join(base_path, folder, filename)
            conn.execute(text(f'TRUNCATE TABLE {table};'))

            df = pd.read_csv(file_path, encoding='utf-8-sig')
            df.columns = df.columns.str.lower().str.strip()
            df.to_sql(table, con=conn, if_exists='append', index=False, chunksize=1000)

            print(f"Sucesso: {table} ({len(df)}) linhas")
            print('-' * 40)
    
        conn.commit()
        
    end = time.time()
    total_time = end - beginning 
    print(f'Os dados foram carregados com sucesso em {total_time:.2f} segundos.')


except Exception as err:
    print(f"Erro: {err}")
