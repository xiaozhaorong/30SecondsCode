# 更新书籍脚本
echo "--------- 开始build书籍 --------"
gitbook build . docs
git add .
git commit -m "Change 更新书籍"
echo "--------- 提交数据到github --------"
git push