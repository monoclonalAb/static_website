document.addEventListener('DOMContentLoaded', () => {
  const links = document.querySelectorAll('a')
  links.forEach(link => {
    const href = link.getAttribute('href')  || ''
    if (href.startsWith('http')) {
      link.setAttribute('target', '_blank')
      link.setAttribute('rel', 'noopener noreferrer');
    }
  })
})
