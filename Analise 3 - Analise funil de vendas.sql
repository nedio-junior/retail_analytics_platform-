-- 3. Análise de Funil de Vendas e Conversão
WITH funil_status AS (
    SELECT 
        status,
        COUNT(*) as total_pedidos,
        SUM(valor_total) as valor_total,
        LAG(COUNT(*)) OVER (ORDER BY 
            CASE status 
                WHEN 'PENDENTE' THEN 1
                WHEN 'APROVADO' THEN 2
                WHEN 'ENVIADO' THEN 3
                WHEN 'ENTREGUE' THEN 4
            END
        ) as status_anterior
    FROM pedidos
    GROUP BY status
)
SELECT 
    status,
    total_pedidos,
    valor_total,
    ROUND((total_pedidos::numeric / FIRST_VALUE(total_pedidos) OVER (ORDER BY 
        CASE status 
            WHEN 'PENDENTE' THEN 1
            WHEN 'APROVADO' THEN 2
            WHEN 'ENVIADO' THEN 3
            WHEN 'ENTREGUE' THEN 4
        END
    ) * 100), 2) as taxa_conversao_total,
    ROUND((total_pedidos::numeric / NULLIF(status_anterior, 0) * 100), 2) as taxa_conversao_etapa
FROM funil_status;