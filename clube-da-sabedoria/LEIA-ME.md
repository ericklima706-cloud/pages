# Clube da Sabedoria: VSL de R$1 (teste A/B do player)

| Endereço | O que é |
|---|---|
| `/` | Use este endereço nos anúncios. Hoje manda todas as visitas para `/vturb/`. Com `TESTE_LIGADO = true` no `index.html`, divide meio a meio entre as duas versões e lembra a escolha de cada pessoa. Só ligue depois que o vídeo estiver em `player/video/`. |
| `/vturb/` | Versão A: player oficial da VTurb (vídeo 691e1c69…). |
| `/player/` | Versão B: player próprio. O vídeo fica em `player/video/` (HLS em 2 qualidades) e o `hls.light.min.js` fica na mesma pasta, então nada depende de outro site. |

As duas versões têm o mesmo botão, o mesmo texto e os mesmos comentários. A única diferença é o player. Se o vídeo tiver um botão configurado no painel da VTurb, desligue esse botão durante o teste.

## Publicar no Cloudflare Pages

Envie o conteúdo desta pasta como a raiz do projeto `clubedasabedoria`: Workers & Pages → clubedasabedoria → Create deployment → arraste a pasta ou o .zip.

Um deploy por upload substitui o site inteiro. Se houver outras páginas publicadas lá, inclua essas páginas no mesmo upload.

## Como medir o teste

O botão manda para o checkout a oferta `e5u3f8ie` com:
- as UTMs do anúncio repassadas;
- o campo `src` marcado com a versão: `pA_…` para a VTurb e `pB_t20_…` para o player próprio, onde `t20` é o segundo do vídeo em que a pessoa clicou. Se a VTurb trocar o `src` pelo dela (`v3_…_691e1c69…`), a venda continua sendo da versão A.

Na exportação de vendas da Hotmart, a coluna **Origem** mostra esse `src`. Compare as vendas de cada versão, que recebem metade das visitas cada uma.

## Comentários

Os comentários são reais, tirados do Instagram da @beatriz.chef, com o nome de usuário encurtado. Para incluir mais, copie um bloco `<div class="msg">` nas duas páginas e troque a inicial, o nome e o texto. Use apenas comentários reais de alunas.

## Trocar o vídeo do player próprio

Rode dentro desta pasta (precisa do ffmpeg):

```
../tools/vsl_hls.sh VIDEO.mp4 player/video
```

O comando gera `master.m3u8` (360p e 720p, começando pela mais leve), os segmentos de 4 segundos e o `poster.jpg`.
