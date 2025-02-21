-- 1. Análise de Cohort de Retenção de Clientes
WITH primeira_compra AS (
    SELECT 
        cliente_id,
        DATE_TRUNC('month', MIN(data_pedido)) as mes_primeira_compra
    FROM pedidos
    GROUP BY cliente_id
),
compras_mensais AS (
    SELECT 
        cliente_id,
        DATE_TRUNC('month', data_pedido) as mes_compra,
        COUNT(DISTINCT id) as num_compras,
        SUM(valor_total) as valor_total
    FROM pedidos
    GROUP BY cliente_id, DATE_TRUNC('month', data_pedido)
),
cohort_analysis AS (
    SELECT 
        pc.mes_primeira_compra,
        COUNT(DISTINCT pc.cliente_id) as clientes_originais,
        DATE_PART('month', cm.mes_compra - pc.mes_primeira_compra) as mes_desde_primeira_compra,
        COUNT(DISTINCT cm.cliente_id) as clientes_retidos,
        SUM(cm.valor_total) as receita_mes
    FROM primeira_compra pc
    LEFT JOIN compras_mensais cm ON pc.cliente_id = cm.cliente_id
    GROUP BY pc.mes_primeira_compra, DATE_PART('month', cm.mes_compra - pc.mes_primeira_compra)
    ORDER BY pc.mes_primeira_compra, mes_desde_primeira_compra
)
select * FROM cohort_analysis;