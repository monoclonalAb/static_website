document.addEventListener('DOMContentLoaded', () => {
  const links = document.querySelectorAll('a')
  links.forEach(link => {
    if (link.href.includes('http')) {
      link.setAttribute('target', '_blank')
      link.setAttribute('rel', 'noopener noreferrer');
    }
  })
})
