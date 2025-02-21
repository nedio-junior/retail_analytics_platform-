-- 2. Margens de lucro por categoria
WITH margem_categoria AS (
    SELECT 
        c.nome as categoria,
        COUNT(DISTINCT p.id) as total_produtos,
        ROUND(AVG(p.margem_lucro)::numeric, 2) as margem_media,
        SUM(ip.quantidade * ip.preco_unitario) as receita_total,
        SUM(ip.quantidade * p.preco_custo) as custo_total
    FROM categorias c
    LEFT JOIN produtos p ON c.id = p.categoria_id
    LEFT JOIN itens_pedido ip ON p.id = ip.produto_id
    GROUP BY c.nome
)
SELECT 
    categoria,
    total_produtos,
    margem_media as margem_media_percentual,
    ROUND(receita_total::numeric, 2) as receita_total,
    ROUND(custo_total::numeric, 2) as custo_total,
    ROUND((receita_total - custo_total)::numeric, 2) as lucro_total,
    ROUND(((receita_total - custo_total) / NULLIF(receita_total, 0) * 100)::numeric, 2) as margem_real_percentual
FROM margem_categoria
WHERE receita_total > 0
ORDER BY lucro_total DESC;