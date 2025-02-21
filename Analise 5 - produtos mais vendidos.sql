-- 1. Produtos mais vendidos (com receita, quantidade e avaliação)
WITH vendas_produto AS (
    SELECT 
        p.id,
        p.nome,
        c.nome as categoria,
        COUNT(DISTINCT ip.pedido_id) as total_pedidos,
        SUM(ip.quantidade) as quantidade_vendida,
        SUM(ip.quantidade * ip.preco_unitario) as receita_total,
        ROUND(AVG(ip.avaliacao_produto)::numeric, 2) as media_avaliacao
    FROM produtos p
    LEFT JOIN categorias c ON p.categoria_id = c.id
    LEFT JOIN itens_pedido ip ON p.id = ip.produto_id
    GROUP BY p.id, p.nome, c.nome
)
SELECT 
    nome,
    categoria,
    quantidade_vendida,
    ROUND(receita_total::numeric, 2) as receita_total,
    media_avaliacao,
    total_pedidos,
    ROUND((quantidade_vendida::numeric / 
        SUM(quantidade_vendida) OVER ()) * 100, 2) as percentual_vendas
FROM vendas_produto
WHERE quantidade_vendida > 0
ORDER BY quantidade_vendida DESC
LIMIT 20;