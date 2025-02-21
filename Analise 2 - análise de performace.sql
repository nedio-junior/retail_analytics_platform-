-- 2. Análise de Performance de Produtos e Categorias
WITH metricas_produto AS (
    SELECT 
        p.id,
        p.nome,
        c.nome as categoria,
        p.preco_venda,
        p.preco_custo,
        p.quantidade_vendida_total,
        p.media_avaliacao,
        SUM(ip.quantidade) as unidades_vendidas,
        SUM(ip.quantidade * ip.preco_unitario) as receita_total,
        SUM(ip.quantidade * (ip.preco_unitario - p.preco_custo)) as lucro_total
    FROM produtos p
    LEFT JOIN categorias c ON p.categoria_id = c.id
    LEFT JOIN itens_pedido ip ON p.id = ip.produto_id
    GROUP BY p.id, p.nome, c.nome, p.preco_venda, p.preco_custo, 
             p.quantidade_vendida_total, p.media_avaliacao
),
rank_produtos AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY receita_total DESC) as rank_categoria,
        ROW_NUMBER() OVER (ORDER BY receita_total DESC) as rank_geral
    FROM metricas_produto
)
SELECT 
    categoria,
    COUNT(*) as total_produtos,
    SUM(receita_total) as receita_categoria,
    SUM(lucro_total) as lucro_categoria,
    AVG(media_avaliacao) as avaliacao_media,
    STRING_AGG(
        CASE WHEN rank_categoria <= 3 
        THEN nome || ' (R$' || ROUND(receita_total::numeric, 2)::text || ')'
        END, 
        ', '
    ) as top_3_produtos
FROM rank_produtos
GROUP BY categoria
ORDER BY receita_categoria DESC;