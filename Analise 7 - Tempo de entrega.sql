-- 3. Tempo médio de entrega
WITH metricas_entrega AS (
    SELECT 
        status,
        COUNT(*) as total_pedidos,
        ROUND(AVG(prazo_entrega)::numeric, 1) as prazo_medio_prometido,
        ROUND(AVG(
            CASE 
                WHEN data_entrega_real IS NOT NULL 
                THEN DATE_PART('day', data_entrega_real - data_pedido)
            END
        )::numeric, 1) as tempo_medio_real,
        ROUND(AVG(avaliacao_entrega)::numeric, 2) as satisfacao_media
    FROM pedidos
    GROUP BY status
)
SELECT 
    status,
    total_pedidos,
    prazo_medio_prometido as prazo_prometido_dias,
    tempo_medio_real as tempo_real_dias,
    CASE 
        WHEN tempo_medio_real > prazo_medio_prometido THEN 'Atrasado'
        ELSE 'No Prazo'
    END as status_entrega,
    satisfacao_media
FROM metricas_entrega
ORDER BY 
    CASE status 
        WHEN 'PENDENTE' THEN 1
        WHEN 'APROVADO' THEN 2
        WHEN 'ENVIADO' THEN 3
        WHEN 'ENTREGUE' THEN 4
    END;